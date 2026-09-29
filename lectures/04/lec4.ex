defmodule Lec4 do
  def create(n \\ 4) do
    Enum.map(1..n, fn _ -> parent = self(); spawn(fn -> loop(parent) end) end)
  end

  def info(pid) when is_pid(pid) do
    case Process.info(pid, [:trap_exit, :links]) do
      nil -> {pid, :dead}
      x -> {pid, x}
    end
  end

  def info(pids) when is_list(pids) do
    Enum.map(pids, &info/1)
  end

  def trap_exit(pid) do
    send(pid, :trap_exit)
  end

  def link(pid, other) do
    send(pid, {:link, other})
  end

  defp loop(parent) do
    receive do
      :trap_exit ->
        Process.flag(:trap_exit, true)
      {:link, other} ->
        Process.link(other)
      x ->
        send(parent, x)
    end
    loop(parent)
  end
end
