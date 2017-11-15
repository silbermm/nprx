defmodule NPRxAuthTest do
  use ExUnit.Case
  doctest NPRx.Auth

  import Mock
  alias NPRx.TestHelpers

  @success_auth TestHelpers.success_auth

  test "authenticates a client" do
    with_mock HTTPoison, [post: fn(_url, _body, _headers) -> @success_auth end] do
      assert NPRx.Auth.authenticate_client() == {:ok, "secret_token"}
    end
  end

  test "authenticates a client and caches token" do
    NPRx.Auth.clear()
    with_mock HTTPoison, [post: fn(_url, _body, _headers) -> @success_auth end] do
      assert NPRx.Auth.authenticate_client() == {:ok, "secret_token"}
    end
    assert NPRx.Auth.authenticate_client() == {:ok, "secret_token"}
  end
end
