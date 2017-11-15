defmodule NPRx.TestHelpers do
  alias HTTPoison.Response
  alias HTTPoison.Error

  def auth_query_string() do
    "grant_type=client_credentials&client_id=client&client_secret=secret"
  end

  def success_auth() do
    {:ok, %Response{status_code: 200, body: "{\"token_type\":\"Bearer\", \"expires_in\":637463877, \"access_token\":\"secret_token\"}"}}
  end

  def fail_auth() do
    {:ok, %Response{status_code: 401, body: ""}}
  end
end

