defmodule RcounterTest do
  use ExUnit.Case
  doctest Rcounter

  test "greets the world" do
    assert Rcounter.hello() == :world
  end
end
