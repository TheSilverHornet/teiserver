defmodule Teiserver.Microblog.PostQueries do
  @moduledoc false
  use CentralWeb, :queries
  alias Teiserver.Microblog.Post

  # Queries
  @spec query_posts(list) :: Ecto.Query.t()
  def query_posts(args) do
    query = from(posts in Post)

    query
    |> do_where([id: args[:id]])
    |> do_where(args[:where])
    |> do_preload(args[:preload])
    |> do_order_by(args[:order_by])
    |> query_select(args[:select])
  end

  @spec do_where(Ecto.Query.t(), list | map | nil) :: Ecto.Query.t()
  defp do_where(query, nil), do: query

  defp do_where(query, params) do
    params
    |> Enum.reduce(query, fn {key, value}, query_acc ->
      _where(query_acc, key, value)
    end)
  end

  @spec _where(Ecto.Query.t(), Atom.t(), any()) :: Ecto.Query.t()
  defp _where(query, _, ""), do: query
  defp _where(query, _, nil), do: query

  defp _where(query, :id, id) do
    from posts in query,
      where: posts.id == ^id
  end

  defp _where(query, :poster_id, poster_id) do
    from posts in query,
      where: posts.poster_id == ^poster_id
  end

  defp _where(query, :poster_id_in, poster_ids) when is_list(poster_ids) do
    from posts in query,
      where: posts.poster_id in ^poster_ids
  end

  defp _where(query, :poster_id_not_in, poster_ids) when is_list(poster_ids) do
    from posts in query,
      where: posts.poster_id not in ^poster_ids
  end

  defp _where(query, :between, {start_date, end_date}) do
    from posts in query,
      where: between(posts.inserted_at, ^start_date, ^end_date)
  end

  defp _where(query, :title_like, title) do
    utitle = "%" <> title <> "%"

    from posts in query,
      where: ilike(posts.title, ^utitle)
  end

  @spec do_order_by(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_order_by(query, nil), do: query
  defp do_order_by(query, params) do
    params
    |> Enum.reduce(query, fn key, query_acc ->
      _order_by(query_acc, key)
    end)
  end

  defp _order_by(query, nil), do: query

  defp _order_by(query, "Newest first") do
    from posts in query,
      order_by: [desc: posts.inserted_at]
  end

  defp _order_by(query, "Oldest first") do
    from posts in query,
      order_by: [asc: posts.inserted_at]
  end

  @spec do_preload(Ecto.Query.t(), List.t() | nil) :: Ecto.Query.t()
  defp do_preload(query, nil), do: query

  defp do_preload(query, preloads) do
    preloads
    |> Enum.reduce(query, fn key, query_acc ->
      _preload(query_acc, key)
    end)
  end

  defp _preload(query, :poster) do
    from posts in query,
      left_join: posters in assoc(posts, :poster),
      preload: [poster: posters]
  end

  # This just grabs the tags
  defp _preload(query, :tags) do
    from posts in query,
      join: tags in assoc(posts, :tags),
      preload: [tags: tags]
  end

  # This applies filtering on which posts we get based on possession of tags
  defp _preload(query, {:tags, [], []}) do
    from posts in query,
      join: tags in assoc(posts, :tags),
      preload: [tags: tags]
  end

  defp _preload(query, {:tags, [], exclude_ids}) do
    from posts in query,
      join: tags in assoc(posts, :tags),
      where: tags.id not in ^exclude_ids,
      preload: [tags: tags]
  end

  defp _preload(query, {:tags, include_ids, []}) do
    from posts in query,
      join: tags in assoc(posts, :tags),
      where: tags.id in ^include_ids,
      preload: [tags: tags]
  end

  defp _preload(query, {:tags, include_ids, exclude_ids}) do
    from posts in query,
      join: tags in assoc(posts, :tags),
      where: tags.id in ^include_ids and tags.id not in ^exclude_ids,
      preload: [tags: tags]
  end
end
