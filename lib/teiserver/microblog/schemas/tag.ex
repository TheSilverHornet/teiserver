defmodule Teiserver.Microblog.Tag do
  @moduledoc false
  use CentralWeb, :schema

  schema "microblog_tags" do
    field :name, :string
    field :colour, :string
    field :icon, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(Map.t(), Map.t()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(name colour icon)a)
    |> validate_required(~w(name colour icon)a)
  end

  @spec authorize(atom, Plug.Conn.t(), Map.t()) :: boolean
  def authorize(_action, conn, _params), do: allow?(conn, "Server")
end
