defmodule ShuxTest do
  use ExUnit.Case
  doctest Shux

  test "Greets shux" do
    assert Shux.hello() == :shux
  end
end
