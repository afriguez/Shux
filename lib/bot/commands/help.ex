defmodule Shux.Bot.Commands.Help do
  @behaviour Shux.Bot.Command

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

  defp process(msg, [], commands) do
    command_list =
      Enum.sort_by(commands, fn {k, _v} -> Atom.to_string(k) end)

    slash_commands = Api.global_commands()

    fields = build_fields(command_list, slash_commands)

    Api.send_message(msg.channel_id, %{
      embeds: [
        %{
          title: "Ayuda Shux",
          description: "Comandos de Shuxbot",
          color: :math.floor(:rand.uniform() * 0xFFFFFF),
          fields: fields
        }
      ]
    })
  end

  defp process(msg, args, commands) do
    command = String.to_atom(hd(args))

    current_command = Map.get(commands, command)

    unless current_command == nil do
      help = current_command.help()

      [slash_cmd | _] = Api.global_commands() |> Enum.filter(&(&1.name == hd(args)))

      Api.send_message(msg.channel_id, %{
        embeds: [
          %{
            title: "Ayuda comando: " <> hd(args),
            description: help.description,
            color: :math.floor(:rand.uniform() * 0xFFFFFF),
            fields: [
              %{
                name: "Uso: ",
                value: help.usage,
                inline: true
              },
              %{
                name: "Slash: ",
                value: "</#{slash_cmd.name}:#{slash_cmd.id}>",
                inline: true
              }
            ]
          }
        ]
      })
    end
  end

  defp build_fields(command_list, slash_commands) do
    for {k, v} <- command_list do
      cmd = Atom.to_string(k)
      filtered_cmds = Enum.filter(slash_commands, &(&1.name == cmd))

      slash_string = build_slash_string(filtered_cmds)

      %{
        name: "#{cmd}" <> slash_string,
        value: v.help().description,
        inline: true
      }
    end
  end

  defp build_slash_string([]), do: ""
  defp build_slash_string([slash_cmd | _]), do: " - </#{slash_cmd.name}:#{slash_cmd.id}>"
end
