defmodule Teiserver.Communication.TextCallbackLib do
  @moduledoc false
  use CentralWeb, :library
  alias Teiserver.{Communication}
  alias Teiserver.Communication.{TextCallback}

  # Functions
  @spec icon :: String.t()
  def icon, do: "fa-regular fa-webhook"

  @spec colours :: atom
  def colours, do: :success2

  @spec make_favourite(Queue.t()) :: Map.t()
  def make_favourite(text_callback) do
    %{
      type_colour: StylingHelper.colours(colours()) |> elem(0),
      type_icon: icon(),
      item_id: text_callback.id,
      item_type: "text_callback",
      item_colour: text_callback.colour,
      item_icon: text_callback.icon,
      item_label: "#{text_callback.name}",
      url: "/teiserver/admin/text_callbacks/#{text_callback.id}"
    }
  end

  # Queries
  @spec query_text_callbacks() :: Ecto.Query.t()
  def query_text_callbacks do
    from(text_callbacks in TextCallback)
  end

  @spec search(Ecto.Query.t(), Map.t() | nil) :: Ecto.Query.t()
  def search(query, nil), do: query

  def search(query, params) do
    params
    |> Enum.reduce(query, fn {key, value}, query_acc ->
      _search(query_acc, key, value)
    end)
  end

  @spec _search(Ecto.Query.t(), atom, any()) :: Ecto.Query.t()
  def _search(query, _, ""), do: query
  def _search(query, _, nil), do: query

  def _search(query, :id, id) do
    from text_callbacks in query,
      where: text_callbacks.id == ^id
  end

  def _search(query, :name, name) do
    from text_callbacks in query,
      where: text_callbacks.name == ^name
  end

  def _search(query, :id_list, id_list) do
    from text_callbacks in query,
      where: text_callbacks.id in ^id_list
  end

  def _search(query, :basic_search, ref) do
    ref_like = "%" <> String.replace(ref, "*", "%") <> "%"

    from text_callbacks in query,
      where: ilike(text_callbacks.name, ^ref_like)
  end

  @spec order_by(Ecto.Query.t(), String.t() | nil) :: Ecto.Query.t()
  def order_by(query, nil), do: query

  def order_by(query, "Name (A-Z)") do
    from text_callbacks in query,
      order_by: [asc: text_callbacks.name]
  end

  def order_by(query, "Name (Z-A)") do
    from text_callbacks in query,
      order_by: [desc: text_callbacks.name]
  end

  def order_by(query, "Newest first") do
    from text_callbacks in query,
      order_by: [desc: text_callbacks.inserted_at]
  end

  def order_by(query, "Oldest first") do
    from text_callbacks in query,
      order_by: [asc: text_callbacks.inserted_at]
  end

  @spec preload(Ecto.Query.t(), List.t() | nil) :: Ecto.Query.t()
  def preload(query, nil), do: query

  def preload(query, _preloads) do
    # query = if :things in preloads, do: _preload_things(query), else: query
    query
  end

  # def _preload_things(query) do
  #   from text_callbacks in query,
  #     left_join: things in assoc(text_callbacks, :things),
  #     preload: [things: things]
  # end

  @spec build_text_callback_cache() :: :ok
  def build_text_callback_cache do
    Communication.list_text_callbacks(limit: :infinity)
    |> Enum.each(fn text_callback ->
      Central.store_put(:text_callback_store, text_callback.id, text_callback)

      text_callback.triggers
      |> Enum.each(fn trigger_text ->
        Central.store_put(:text_callback_trigger_lookup, trigger_text, text_callback.id)
      end)
    end)
  end

  @spec update_text_callback_cache({:ok, TextCallback.t()} | {:error, Ecto.Changeset.t()}) ::
          {:ok, TextCallback.t()} | {:error, Ecto.Changeset.t()}
  def update_text_callback_cache({:ok, text_callback} = args) do
    Central.store_put(:text_callback_store, text_callback.id, text_callback)

    text_callback.triggers
    |> Enum.each(fn trigger_text ->
      Central.store_put(:text_callback_trigger_lookup, trigger_text, text_callback.id)
    end)

    args
  end

  def update_text_callback_cache(args), do: args

  @spec lookup_text_callback_from_trigger(String.t()) :: TextCallback.t() | nil
  def lookup_text_callback_from_trigger(trigger) do
    trigger =
      trigger
      |> String.trim()
      |> String.downcase()

    case Central.store_get(:text_callback_trigger_lookup, trigger) do
      nil ->
        nil

      id ->
        case Central.store_get(:text_callback_store, id) do
          nil -> nil
          text_callback -> text_callback
        end
    end
  end
end
