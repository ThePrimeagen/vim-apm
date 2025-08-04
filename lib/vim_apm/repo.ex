defmodule VimApm.Repo do
  use Ecto.Repo,
    otp_app: :vim_apm,
    adapter: Ecto.Adapters.SQLite3
end
