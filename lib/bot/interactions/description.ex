defmodule Shux.Bot.Interactions.Description do
  import Bitwise

  alias Shux.Api
  alias Shux.Discord
  alias Shux.Bot.Components

  def run(interaction) do
    response = run_desc(interaction)
    Discord.Api.interaction_callback(interaction, response)
  end

  defp run_desc(%{
         data: %{
           custom_id: "update_description-" <> user_id,
           components: [%{components: [%{value: description}]}]
         },
         guild_id: guild_id
       }) do
    Api.set_description(guild_id, user_id, description)

    %{
      type: 4,
      data: %{
        content: "Tu descripcion ha sido actualizada.",
        flags: 1 <<< 6
      }
    }
  end

  defp run_desc(%{
         data: %{custom_id: "description-" <> user_id},
         member: %{user: %{id: id}}
       })
       when id != user_id do
    %{
      type: 4,
      data: %{
        content: "No puedes editar la descripcion de alguien mas.",
        flags: 1 <<< 6
      }
    }
  end

  defp run_desc(%{data: %{custom_id: "description-" <> user_id}}) do
    %{
      type: 9,
      data:
        Components.modal(
          title: "Actualizar Descripcion",
          custom_id: "update_description-#{user_id}",
          components: [
            Components.action_row([
              Components.text_input(
                custom_id: "updated_description-#{user_id}",
                style: 2,
                label: "Descripcion",
                placeholder: "descripcion",
                required: true,
                min_length: 1,
                max_length: 250
              )
            ])
          ]
        )
    }
  end
end
