defmodule DynamicCountersTest do
  use ExUnit.Case
  doctest DynamicCounters

  test "greets the world" do
    assert DynamicCounters.hello() == :world
  end
end
