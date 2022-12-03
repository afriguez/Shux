defmodule Shux.Bot.Handlers.MessageHandler do
  def handle(data) do
  end

  def handle(data, :deleted) do
  end

  def handle(data, :edited) do
  end

  def is_command?(content) do
    String.starts_with?(content, ["shux!", "shx!", "sh!", "sx!"])
  end
end
