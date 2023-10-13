defmodule Shux.Bot.Components do
  def action_row(components) when is_list(components), do: %{type: 1, components: components}

  def action_row(_components), do: {:error, "Components must be a list"}

  def button(props \\ []) do
    %{
      type: 2,
      style: Keyword.get(props, :style, 0),
      label: Keyword.get(props, :label, nil),
      emoji: Keyword.get(props, :emoji, nil),
      custom_id: Keyword.get(props, :custom_id, nil),
      url: Keyword.get(props, :url, nil),
      disabled: Keyword.get(props, :disabled, nil)
    }
  end

  def string_select(props \\ []) do
    %{
      type: 3,
      custom_id: Keyword.get(props, :custom_id, nil),
      options: Keyword.get(props, :options, nil),
      placeholder: Keyword.get(props, :placeholder, nil)
    }
  end

  def string_option(props \\ []) do
    %{
      label: Keyword.get(props, :label, nil),
      value: Keyword.get(props, :label, nil),
      description: Keyword.get(props, :label, nil),
      emoji: Keyword.get(props, :emoji, nil)
    }
  end
end
