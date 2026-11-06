defmodule Chat.Server do
  @moduledoc """
  Globally registered chat service responsible for nicknames and delivery.

  The application owns the ETS tables so nickname state remains available if
  this supervised process is restarted. The GenServer serializes registration
  requests, which prevents two clients from acquiring the same nickname.
  """

  use GenServer
  require Logger

  @name {:global, __MODULE__}
  @nicknames Chat.Nicknames
  @clients Chat.Clients

  # Client API
  @doc "Starts the globally registered server under a supervisor."
  def start_link(_arg) do
    GenServer.start_link(__MODULE__, nil, name: @name)
  end

  @doc "Registers, or renames, the proxy worker with `nickname`."
  def register(worker, nickname) do
    GenServer.call(@name, {:register, worker, nickname})
  end

  @doc "Returns the currently registered nicknames in sorted order."
  def list_users do
    GenServer.call(@name, :list_users)
  end

  @doc "Delivers a message and returns any recipient nicknames not in use."
  def send_message(sender, recipients, message) do
    GenServer.call(@name, {:send_message, sender, recipients, message})
  end

  @doc "Removes the nickname associated with a disconnected proxy worker."
  def remove(worker) do
    GenServer.cast(@name, {:remove, worker})
  end

  # Server implementation
  @impl true
  def init(_arg) do
    monitors =
      @clients
      |> :ets.tab2list()
      |> Enum.reduce(%{}, fn {worker, _nickname}, monitors ->
        if Process.alive?(worker) do
          Map.put(monitors, worker, Process.monitor(worker))
        else
          remove_stale_worker(worker)
          monitors
        end
      end)

    Logger.info("chat server started with #{map_size(monitors)} registered client(s)")
    {:ok, monitors}
  end

  @impl true
  def handle_call({:register, worker, nickname}, _from, monitors) do
    case :ets.lookup(@nicknames, nickname) do
      [] ->
        {monitors, old_nickname} = ensure_monitored(monitors, worker)
        replace_nickname(worker, old_nickname, nickname)
        log_registration(old_nickname, nickname)
        {:reply, :ok, monitors}

      [{^nickname, ^worker}] ->
        {:reply, :ok, monitors}

      [{^nickname, _other_worker}] ->
        {:reply, {:error, :nickname_taken}, monitors}
    end
  end

  @impl true
  def handle_call(:list_users, _from, monitors) do
    users =
      @nicknames
      |> :ets.tab2list()
      |> Enum.map(fn {nickname, _worker} -> nickname end)
      |> Enum.sort()

    {:reply, users, monitors}
  end

  @impl true
  def handle_call({:send_message, sender, recipients, message}, _from, monitors) do
    case :ets.lookup(@clients, sender) do
      [] ->
        {:reply, {:error, :not_registered}, monitors}

      [{^sender, sender_nickname}] ->
        unknown = deliver(recipients, sender_nickname, message)
        delivered = recipients |> Enum.uniq() |> length() |> Kernel.-(length(unknown))

        Logger.info(
          "#{sender_nickname} dispatched a message to #{delivered} client(s); " <>
            "#{length(unknown)} unknown recipient(s)"
        )

        {:reply, {:ok, unknown}, monitors}
    end
  end

  @impl true
  def handle_cast({:remove, worker}, monitors) do
    {:noreply, remove_worker(worker, monitors)}
  end

  @impl true
  def handle_info({:DOWN, reference, :process, worker, _reason}, monitors) do
    case Map.get(monitors, worker) do
      ^reference -> {:noreply, remove_worker(worker, monitors, false)}
      _other_reference -> {:noreply, monitors}
    end
  end

  defp ensure_monitored(monitors, worker) do
    old_nickname =
      case :ets.lookup(@clients, worker) do
        [] -> nil
        [{^worker, nickname}] -> nickname
      end

    monitors =
      if Map.has_key?(monitors, worker) do
        monitors
      else
        Map.put(monitors, worker, Process.monitor(worker))
      end

    {monitors, old_nickname}
  end

  defp replace_nickname(worker, old_nickname, new_nickname) do
    if old_nickname != nil do
      :ets.delete(@nicknames, old_nickname)
    end

    :ets.insert(@nicknames, {new_nickname, worker})
    :ets.insert(@clients, {worker, new_nickname})
  end

  defp deliver(recipients, sender_nickname, message) do
    recipients
    |> Enum.uniq()
    |> Enum.reduce([], fn nickname, unknown ->
      case :ets.lookup(@nicknames, nickname) do
        [{^nickname, worker}] ->
          GenServer.cast(worker, {:chat_message, sender_nickname, message})
          unknown

        [] ->
          [nickname | unknown]
      end
    end)
    |> Enum.reverse()
  end

  defp remove_worker(worker, monitors, demonitor? \\ true) do
    case :ets.lookup(@clients, worker) do
      [] ->
        Map.delete(monitors, worker)

      [{^worker, nickname}] ->
        :ets.delete(@clients, worker)
        :ets.delete(@nicknames, nickname)

        if demonitor? do
          case Map.get(monitors, worker) do
            nil -> :ok
            reference -> Process.demonitor(reference, [:flush])
          end
        end

        Logger.info("#{nickname} removed")
        Map.delete(monitors, worker)
    end
  end

  defp remove_stale_worker(worker) do
    case :ets.lookup(@clients, worker) do
      [{^worker, nickname}] ->
        :ets.delete(@clients, worker)
        :ets.delete(@nicknames, nickname)

      [] ->
        :ok
    end
  end

  defp log_registration(nil, nickname), do: Logger.info("#{nickname} registered")

  defp log_registration(old_nickname, nickname) do
    Logger.info("#{old_nickname} -> #{nickname} renamed")
  end
end
