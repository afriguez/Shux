defmodule Shux.Bot.Commands.Warn do
  @behaviour Shux.Bot.Command

  def help() do
    %{
      usage: "sx!warn @user",
      description: "Warnea a un usuario.",
      perms: :mod,
      options: ""
    }
  end

  def run(:admin, msg, args), do: run(:mod, msg, args)

  def run(:mod, msg, args) do
    {:ok, nil}
  end

  def run(_perms, _msg, _args), do: {:invalid, "Not authorized"}
end
