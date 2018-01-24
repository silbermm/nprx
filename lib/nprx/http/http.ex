defmodule NPRx.HTTP do
  @moduledoc false

  @app_id Application.get_env(:nprx, :npr_app_id)
  @app_secret Application.get_env(:nprx, :npr_app_secret)
  @base_url "https://api.npr.org"

  def get_token() do
    HTTPoison.post("#{@base_url}/authorization/v2/token", auth_body(), %{
      "Content-type" => "application/x-www-form-urlencoded"})
    |> parse_body
    |> case do
      {:ok, res} -> {:ok, Map.get(res, "access_token")}
      other -> other
    end
  end

  def get(path, token, params \\ []) do
    path
    |> make_get_call(token, params)
    |> parse_body
  end

  defp auth_body() do
    ["grant_type=client_credentials",
     "&client_id=#{URI.encode_www_form(@app_id)}",
     "&client_secret=#{URI.encode_www_form(@app_secret)}"]
    |> Enum.join
  end

  defp decode_body(body) do
    body
    |> Poison.decode
    |> case do
      {:ok, decoded} -> decoded
      {:error, reason} -> %{}
      _ -> %{}
    end
  end

  defp make_get_call(path, auth, params) do
    opts = [hackney: [pool: :default], timeout: 2000]
    HTTPoison.get("#{@base_url}#{path}#{stringify_url_params(params)}", %{"Authorization" => "Bearer #{auth}"}, opts)
  end

  defp parse_body({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, decode_body(body)}
  end
  defp parse_body({:ok, %HTTPoison.Response{body: body}}) do
    {:error, Poison.decode!(body)}
  end
  defp parse_body({:error, %HTTPoison.Error{reason: reason}}), do: {:error, reason}

  @spec stringify_url_params(keyword() | []) :: binary()
  defp stringify_url_params([]), do: ""
  defp stringify_url_params(opts) do
    options =
      opts
      |> unique_keys
      |> Enum.reduce([], fn(key, acc) ->
        vals =
          opts
          |> Keyword.get_values(key)
          |> Enum.map(fn(x) -> URI.encode("#{key}=#{x}") end)
            acc ++ vals
      end)
      |> Enum.join("&")
    "?#{options}"
  end

  @spec unique_keys(Keyword.t) :: list()
  defp unique_keys(keyword_list) do
    keyword_list
    |> Enum.uniq_by(fn {k, _} -> k end)
    |> Keyword.keys
  end
end
