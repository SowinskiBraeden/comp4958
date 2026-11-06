defmodule Chat.Proxy.Worker do
  @moduledoc """
  Represents one external TCP client.

  A worker validates commands, stores that client's private named/default
  groups, and delegates nickname and delivery operations to `Chat.Server`.
  """

  use GenServer
  require Logger

  defstruct socket: nil, nickname: nil, groups: %{}, default_group: nil

  @doc "Starts an unlinked worker for the accepted TCP socket."
  def start(socket) do
    GenServer.start(__MODULE__, socket)
  end

  @impl true
  def init(socket) do
    {:ok, %__MODULE__{socket: socket}}
  end

  @impl true
  def handle_info(:socket_ready, state) do
    :ok = :inet.setopts(state.socket, active: :once)
    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp, socket, line}, %{socket: socket} = state) do
    new_state = process_line(line, state)
    :ok = :inet.setopts(socket, active: :once)
    {:noreply, new_state}
  end

  @impl true
  def handle_info({:tcp_closed, socket}, %{socket: socket} = state) do
    Chat.Server.remove(self())
    :gen_tcp.close(socket)
    Logger.info("client disconnected: #{inspect(socket)}")
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:tcp_error, socket, reason}, %{socket: socket} = state) do
    Chat.Server.remove(self())
    :gen_tcp.close(socket)
    Logger.warning("client socket error: #{inspect(reason)}")
    {:stop, :normal, state}
  end

  @impl true
  def handle_cast({:chat_message, sender, message}, state) do
    send_line(state, "#{sender}: #{message}")
    {:noreply, state}
  end

  defp process_line(line, state) do
    words = line |> String.trim() |> String.split(~r/\s+/, trim: true)

    case words do
      [] ->
        error(state, "invalid command")

      [first | arguments] ->
        case command(first) do
          :invalid -> error(state, "invalid command")
          command -> execute(command, arguments, state)
        end
    end
  end

  defp command(word) do
    # Only the first two characters matter, so /m, /M and /message agree.
    case word |> String.slice(0, 2) |> String.upcase() do
      "/B" -> :broadcast
      "/D" -> :default
      "/G" -> :group
      "/L" -> :list
      "/M" -> :message
      "/N" -> :nickname
      _ -> :invalid
    end
  end

  defp execute(:nickname, [], state), do: error(state, "nickname required")

  defp execute(:nickname, [nickname | _extra], state) do
    cond do
      not valid_nickname?(nickname) ->
        error(state, "invalid nickname")

      true ->
        case Chat.Server.register(self(), nickname) do
          :ok ->
            send_line(state, "nickname set to #{nickname}")
            %{state | nickname: nickname}

          {:error, :nickname_taken} ->
            error(state, "nickname taken")
        end
    end
  end

  defp execute(:list, _arguments, state) do
    users = Chat.Server.list_users()
    send_line(state, "users: #{Enum.join(users, ", ")}")
    state
  end

  defp execute(command, _arguments, %{nickname: nil} = state)
       when command in [:message, :group, :default, :broadcast] do
    error(state, "you must set a nickname first")
  end

  defp execute(:message, arguments, state) when length(arguments) < 2 do
    error(state, "recipients and message required")
  end

  defp execute(:message, [names | message_words], state) do
    with {:ok, recipients} <- expand_names(names, state.groups) do
      message = Enum.join(message_words, " ")
      report_delivery(Chat.Server.send_message(self(), recipients, message), state)
    else
      {:error, :invalid_name} -> error(state, "invalid recipient name")
    end
  end

  defp execute(:group, arguments, state) when length(arguments) < 2 do
    error(state, "group name and members required")
  end

  defp execute(:group, [group_name, names | _extra], state) do
    cond do
      not valid_group_name?(group_name) ->
        error(state, "invalid group name")

      true ->
        case expand_names(names, state.groups) do
          {:ok, members} ->
            send_line(state, "group #{group_name} set")
            %{state | groups: Map.put(state.groups, group_name, members)}

          {:error, :invalid_name} ->
            error(state, "invalid group member name")
        end
    end
  end

  defp execute(:default, [], state), do: error(state, "default group members required")

  defp execute(:default, [names | _extra], state) do
    case expand_names(names, state.groups) do
      {:ok, members} ->
        send_line(state, "default group set")
        %{state | default_group: members}

      {:error, :invalid_name} ->
        error(state, "invalid default group member name")
    end
  end

  defp execute(:broadcast, [], state), do: error(state, "message required")

  defp execute(:broadcast, _message, %{default_group: nil} = state) do
    error(state, "default group is not set")
  end

  defp execute(:broadcast, message_words, state) do
    message = Enum.join(message_words, " ")
    report_delivery(Chat.Server.send_message(self(), state.default_group, message), state)
  end

  defp expand_names(names, groups) do
    # Unknown group names intentionally expand to an empty list, as required.
    names
    |> String.split(",", trim: false)
    |> Enum.reduce_while([], fn name, recipients ->
      cond do
        valid_nickname?(name) ->
          {:cont, [name | recipients]}

        valid_group_name?(name) ->
          {:cont, Enum.reverse(Map.get(groups, name, []), recipients)}

        true ->
          {:halt, {:error, :invalid_name}}
      end
    end)
    |> case do
      {:error, :invalid_name} = error -> error
      recipients -> {:ok, recipients |> Enum.reverse() |> Enum.uniq()}
    end
  end

  defp valid_nickname?(name), do: Regex.match?(~r/^[a-z][A-Za-z0-9_]{1,19}$/, name)
  defp valid_group_name?(name), do: Regex.match?(~r/^[A-Z][A-Za-z0-9_]{1,19}$/, name)

  defp report_delivery({:ok, []}, state), do: state

  defp report_delivery({:ok, unknown}, state) do
    Enum.each(unknown, fn nickname -> send_line(state, "unknown user #{nickname}") end)
    state
  end

  defp report_delivery({:error, :not_registered}, state) do
    error(state, "you must set a nickname first")
  end

  defp error(state, message) do
    send_line(state, "error: #{message}")
    state
  end

  defp send_line(state, message) do
    :gen_tcp.send(state.socket, message <> "\n")
  end
end
