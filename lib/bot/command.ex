defmodule Shux.Bot.Command do
  @type help_map :: %{
          usage: String.t(),
          description: String.t(),
          perms: String.t(),
          options: String.t()
        }

  @callback help() :: help_map()

  @callback run(
              perms :: atom(),
              content :: String.t(),
              args :: list(),
              opts :: list()
            ) ::
              {:ok, any()} | {:invalid, String.t()} | {:error, String.t()}
end
