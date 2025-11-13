defmodule PipelinesElixirTest do
  use ExUnit.Case
  doctest PipelinesElixir

  test "greets the world" do
    assert PipelinesElixir.hello() == :world
  end
end
