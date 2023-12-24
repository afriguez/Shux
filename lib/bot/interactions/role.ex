defmodule Shux.Bot.Interactions.Role do
  alias Shux.Discord.Api

  def run(%{data: %{custom_id: "role-" <> role_id}} = interaction) do
    %{roles: member_roles} = interaction.member

    roles =
      if role_id in member_roles,
        do: member_roles -- [role_id],
        else: member_roles ++ [role_id]

    Api.update_member(interaction.guild_id, interaction.member.user.id, %{
      roles: roles
    })

    Api.interaction_callback(interaction, %{
      type: 4,
      data: %{content: "Se han actualizado tus roles.", flags: 64}
    })
  end
end
