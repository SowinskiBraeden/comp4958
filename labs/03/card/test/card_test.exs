defmodule CardTest do
  use ExUnit.Case

  setup do
    {:ok, pid} = Card.Worker.start()
    on_exit(fn ->
      if Process.alive?(pid), do: GenServer.stop(pid)
    end)

    :ok
  end

  test "the server creates a fresh deck when it starts" do
    assert Card.Worker.count() == 52
  end

  test "dealing removes cards from the server's deck" do
    assert {:ok, cards} = Card.Worker.deal(5)
    assert length(cards) == 5
    assert Card.Worker.count() == 47
  end

  test "new replaces the current deck with a fresh deck" do
    assert {:ok, _cards} = Card.Worker.deal(5)
    Card.Worker.new()

    assert Card.Worker.count() == 52
  end
end
