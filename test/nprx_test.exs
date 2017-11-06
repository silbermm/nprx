defmodule NPRTest do
  use ExUnit.Case
  doctest NPR

  test "greets the world" do
    assert NPR.hello() == :world
  end
end
