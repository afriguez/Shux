defmodule Shux.Bot.Commands.Help do
  @behaviour Shux.Bot.Command

  alias Shux.Discord.Api
  alias Shux.Bot.Handlers.MessageHandler

  def help() do
    %{
      usage: "sx!help comando",
      description: "Muestra ayuda de un comando",
      perms: :user,
      options: ""
    }
  end

  def run(perms, msg, args) do
    commands = MessageHandler.get_commands()
    process(msg, args, commands, perms)
  end

  defp process(msg, [], commands, perms) do
    command_list =
      Enum.sort_by(commands, fn {k, _v} -> Atom.to_string(k) end)

    slash_commands = Api.global_commands()

    fields = build_fields(command_list, slash_commands, perms)

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

  defp process(msg, args, commands, perms) do
    command = String.to_atom(hd(args))

    current_command = Map.get(commands, command)

    unless current_command == nil do
      role_flags = Shux.Api.get_role_flags()
      user_flags = role_flags[perms]
      flags = role_flags[current_command.help().perms]

      if flags >= user_flags do
        help = current_command.help()
        global = Api.global_commands() |> Enum.filter(&(&1.name == hd(args)))

        fields =
          if Enum.empty?(global),
            do: [
              %{
                name: "Uso: ",
                value: help.usage,
                inline: true
              }
            ],
            else: [
              %{
                name: "Uso: ",
                value: help.usage,
                inline: true
              },
              %{
                name: "Slash: ",
                value: "</#{hd(global).name}:#{hd(global).id}>",
                inline: true
              }
            ]

        Api.send_message(msg.channel_id, %{
          embeds: [
            %{
              title: "Ayuda comando: " <> hd(args),
              description: help.description,
              color: :math.floor(:rand.uniform() * 0xFFFFFF),
              fields: fields
            }
          ]
        })
      else
        {:invalid, "Not authorized"}
      end
    end
  end

  defp build_fields(command_list, slash_commands, perms) do
    role_flags = Shux.Api.get_role_flags()
    user_flags = role_flags[perms]

    for {k, v} <- command_list do
      flags = role_flags[v.help().perms]
      cmd = Atom.to_string(k)

      if flags >= user_flags do
        filtered_cmds = Enum.filter(slash_commands, &(&1.name == cmd))

        slash_string = build_slash_string(filtered_cmds)

        %{
          name: "#{cmd}" <> slash_string,
          value: v.help().description,
          inline: true
        }
      else
        nil
      end
    end
    |> Enum.filter(&(&1 != nil))
  end

  defp build_slash_string([]), do: ""
  defp build_slash_string([slash_cmd | _]), do: " - </#{slash_cmd.name}:#{slash_cmd.id}>"
end
