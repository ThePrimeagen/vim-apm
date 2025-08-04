defmodule VimApm.OAuth.Twitch do
  use OAuth2.Strategy

  def client do
    OAuth2.Client.new([
      strategy: OAuth2.Strategy.AuthCode,
      client_id: Application.fetch_env!(:vim_apm, :client_id),
      client_secret: Application.fetch_env!(:vim_apm, :client_secret),
      site: "https://id.twitch.tv/helix",
      authorize_url: "https://id.twitch.tv/oauth2/authorize",
      token_url: "https://id.twitch.tv/oauth2/token",
      redirect_uri: Application.fetch_env!(:vim_apm, :twitch_redirect_uri),
    ])
    |> OAuth2.Client.put_serializer("application/json", Jason)
  end

  def authorize_url! do
    OAuth2.Client.authorize_url!(client(), scope: "user:read:email")
  end

  def get_token!(params \\ [], headers \\ [], opts \\ []) do
    # Twitch expects the `client_id` and *also* the `client_secret` **in the POST body** when exchanging
    # the authorization code for an access token. The default OAuth2 behaviour sends the credentials
    # via the `Authorization: Basic` header which Twitch ignores, responding with `missing_secret`.

    params = Keyword.put_new(params, :client_secret, Application.fetch_env!(:vim_apm, :client_secret))

    OAuth2.Client.get_token!(client(), params, headers, opts)
  end

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end



