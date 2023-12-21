defmodule Shux.Bot.Commands.Addcolor do
  @behaviour Shux.Bot.Command

  alias Shux.Discord.Cache
  alias Shux.Discord.Api

  def help() do
    %{
      usage: "sx!addcolor",
      description: "Agrega un rol a la lista de colores.",
      perms: :admin,
      options: "-l Numero"
    }
  end

  def run(:admin, msg, ["<@" <> _role_id, "-l", level]) do
    try do
      level = String.to_integer(level)
      [role_id | _t] = msg.mention_roles
      guild = Cache.get_guild(msg.guild_id)

      role =
        guild.roles
        |> Enum.find(fn r -> r.id == role_id end)

      Shux.Api.post_role(
        msg.guild_id,
        role.id,
        role.name,
        Shux.Api.get_role_flags().colour,
        level
      )

      Api.send_message(
        msg.channel_id,
        "El rol con id #{role.id} ha sido agregado a la lista de colores."
      )

      {:ok, nil}
    rescue
      _ -> Api.send_message(msg.channel_id, "El nivel debe ser un número.")
    end
  end

  def run(:admin, _msg, _args), do: {:invalid, "Bad format"}
  def run(_perms, _msg, _args), do: {:invalid, "Not authorized"}
end
