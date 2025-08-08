import Config
import Dotenvy

base_dir = Path.expand("./")
source! Path.absname(".env", base_dir)

if config_env() == :prod do
  config :vim_apm, :twitch_redirect_uri, "https://vim-apm.theprimeagen.com/auth/twitch/callback"
else
  config :vim_apm, :twitch_redirect_uri, "http://localhost:4000/auth/twitch/callback"
end

config :vim_apm, :client_id, env!("TWITCH_CLIENT_ID")
config :vim_apm, :client_secret, env!("TWITCH_CLIENT_SECRET")
config :ecto_sql, log: true
config :vim_apm, :motion_last_few, 3
config :vim_apm, :characters_per_word, 5

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/vim_apm start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :vim_apm, VimApmWeb.Endpoint, server: true
end

if config_env() == :prod do
  # Configure your database
  config :vim_apm, VimApm.Repo,
    database: Path.expand("../vim_apm_dev.db", __DIR__),
    pool_size: 5,
    stacktrace: true,
    show_sensitive_data_on_connection_error: true

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  # For development, we disable any cache and enable
  # debugging and code reloading.
  #
  # The watchers configuration can be used to run external
  # watchers to your application. For example, we can use it
  # to bundle .js and .css sources.
  config :vim_apm, VimApmWeb.Endpoint,
    # Binding to loopback ipv4 address prevents access from other machines.
    # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
    http: [ip: {127, 0, 0, 1}, port: 4000],
    check_origin: false,
    code_reloader: true,
    debug_errors: true,
    secret_key_base: "NZ3Fxylzll85A/19vhOL4vq5DmVyYKcP9gSbBg/rAaj7HDzhfbsfBo/SONWw18ab",
    watchers: [
      esbuild: {Esbuild, :install_and_run, [:vim_apm, ~w(--sourcemap=inline --watch)]},
      tailwind: {Tailwind, :install_and_run, [:vim_apm, ~w(--watch)]}
    ]

  config :vim_apm, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :vim_apm, VimApmWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :vim_apm, VimApmWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :vim_apm, VimApm.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
