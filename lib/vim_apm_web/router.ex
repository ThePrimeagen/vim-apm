defmodule VimApmWeb.Router do
  use VimApmWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {VimApmWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", VimApmWeb do
    pipe_through :browser
    get "/twitch", AuthController, :request
    get "/twitch/callback", AuthController, :callback
    get "/reset-token", AuthController, :reset_token
  end

  scope "/", VimApmWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api", VimApmWeb.Api do
    pipe_through :api

    post "/motions", VimMessageController, :motions
  end

  # Other scopes may use custom stacks.
  # scope "/api", VimApmWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:vim_apm, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: VimApmWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
