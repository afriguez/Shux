defmodule Shux.Bot.Handlers.MessageHandler do
  @commands %{
    help: Commands.Help
  }

  def handle(data) do
    if is_command?(data.content) do
      [command | tail] =
        data.content
        |> String.split("!")
        |> tl()
        |> List.to_string()
        |> String.split()

      content = List.to_string(tail)
      args = String.downcase(content) |> String.split()
      opts = []

      current_command = Map.get(@commands, command)

      unless current_command == nil do
        {_status, _message} = current_command.run(:user, content, args, opts)
      end
    end
  end

  def handle(data, :deleted) do
  end

  def handle(data, :edited) do
  end

  def is_command?(content) do
    String.starts_with?(content, ["shux!", "shx!", "sh!", "sx!"])
  end
end
