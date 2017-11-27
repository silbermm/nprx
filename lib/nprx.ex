defmodule NPRx do
  @moduledoc """
  Interact with the NPR One API.

  ** Work in progress **

  Currently all that is implemented is authenticating an application AND searching for stations.

  First you'll have to add an application [at the  NPR developer console](https://dev.npr.org/console)

  Some initial configuration is required:
  ```
  config :my_app,
    npr_app_id: "your_app_id",
    npr_app_secret: "your_app_secret"
  ```

  Now you can get a token from the API to reuse in subsequent requests. 
  ```
  {:ok, token} = NPRx.Auth.authenticate_client()
  {:ok, stations_near_me} = NPRx.StationFinder.stations(token)
  ```
  """

end
