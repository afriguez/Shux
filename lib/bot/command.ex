defmodule Shux.Bot.Command do
  @type help_map :: %{
          usage: String.t(),
          description: String.t(),
          perms: atom(),
          options: String.t()
        }

  @callback help() :: help_map()

  @callback run(
              perms :: atom(),
              msg :: any(),
              args :: list()
            ) ::
              {:ok, any()} | {:invalid, String.t()} | {:error, String.t()}
end
