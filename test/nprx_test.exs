defmodule NPRTest do
  use ExUnit.Case
  doctest NPRx

  import Mock
  alias NPRx.TestHelpers

  @success_auth TestHelpers.success_auth

  test "authenticates a client" do
    with_mock HTTPoison, [post: fn(_url, _headers) -> @success_auth end] do
    
    end
  end
end
