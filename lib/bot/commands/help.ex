defmodule Shux.Bot.Commands.Help do
  alias Shux.Discord.Api
  alias Shux.Bot.Handlers.MessageHandler

  def help() do
    %{
      usage: "sx!help comando",
      description: "Muestra ayuda de un comando",
      perms: :tech,
      options: ""
    }
  end

  def run(_perms, msg, args) do
    commands = MessageHandler.get_commands()
    process(msg, args, commands)
  end

  def process(msg, [], commands) do
    list =
      Enum.map(commands, fn {k, v} ->
        %{
          name: Atom.to_string(k),
          value: v.help().description, inline: true
        }
      end)

    Api.send_message(msg.channel_id, %{
      embeds: [
        %{
          title: "Ayuda Shux",
          description: help().description,
          color: :math.floor(:rand.uniform() * 0xFFFFFF),
          fields: list
        }
      ]
    })
  end

  def process(msg, args, commands) do
    command = String.to_atom(hd(args))

    current_command = Map.get(commands, command)

    unless current_command == nil do
      help = current_command.help()

      Api.send_message(msg.channel_id, %{
        embeds: [
          %{
            title: "Ayuda commando: " <> hd(args),
            description: help.description,
            color: :math.floor(:rand.uniform() * 0xFFFFFF),
            fields: [
              %{
                name: "Uso: ",
                value: help.usage,
                inline: true
              }
            ]
          }
        ]
      })
    end
  end
end
