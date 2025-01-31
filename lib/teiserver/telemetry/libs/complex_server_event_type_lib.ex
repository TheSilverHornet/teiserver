defmodule Teiserver.Telemetry.ComplexServerEventTypeLib do
  @moduledoc false
  use CentralWeb, :library_newform
  alias Teiserver.Telemetry.{ComplexServerEventType, ComplexServerEventTypeQueries}

  # Helper function
  @spec get_or_add_complex_server_event_type(String.t()) :: non_neg_integer()
  def get_or_add_complex_server_event_type(name) do
    name = String.trim(name)

    Central.cache_get_or_store(:telemetry_complex_server_event_types_cache, name, fn ->
      query = ComplexServerEventTypeQueries.query_complex_server_event_types(where: [name: name], select: [:id], order_by: ["ID (Lowest first)"])
      case Repo.all(query) do
        [] ->
          {:ok, event_type} =
            %ComplexServerEventType{}
            |> ComplexServerEventType.changeset(%{name: name})
            |> Repo.insert()

          event_type.id

        [%{id: id} | _] ->
          id
      end
    end)
  end

  @doc """
  Returns the list of complex_server_event_types.

  ## Examples

      iex> list_complex_server_event_types()
      [%ComplexServerEventType{}, ...]

  """
  @spec list_complex_server_event_types() :: [ComplexServerEventType]
  @spec list_complex_server_event_types(list) :: [ComplexServerEventType]
  def list_complex_server_event_types(args \\ []) do
    args
    |> ComplexServerEventTypeQueries.query_complex_server_event_types()
    |> Repo.all()
  end

  @doc """
  Gets a single complex_server_event_type.

  Raises `Ecto.NoResultsError` if the ComplexServerEventType does not exist.

  ## Examples

      iex> get_complex_server_event_type!(123)
      %ComplexServerEventType{}

      iex> get_complex_server_event_type!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_complex_server_event_type!(non_neg_integer) :: ComplexServerEventType
  @spec get_complex_server_event_type!(non_neg_integer, list) :: ComplexServerEventType
  def get_complex_server_event_type!(id), do: Repo.get!(ComplexServerEventType, id)

  def get_complex_server_event_type!(id, args) do
    args = args ++ [id: id]

    args
    |> ComplexServerEventTypeQueries.query_complex_server_event_types()
    |> Repo.one!()
  end

  @doc """
  Creates a complex_server_event_type.

  ## Examples

      iex> create_complex_server_event_type(%{field: value})
      {:ok, %ComplexServerEventType{}}

      iex> create_complex_server_event_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_complex_server_event_type() :: {:ok, ComplexServerEventType} | {:error, Ecto.Changeset}
  @spec create_complex_server_event_type(map) :: {:ok, ComplexServerEventType} | {:error, Ecto.Changeset}
  def create_complex_server_event_type(attrs \\ %{}) do
    %ComplexServerEventType{}
    |> ComplexServerEventType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a complex_server_event_type.

  ## Examples

      iex> update_complex_server_event_type(complex_server_event_type, %{field: new_value})
      {:ok, %ComplexServerEventType{}}

      iex> update_complex_server_event_type(complex_server_event_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_complex_server_event_type(ComplexServerEventType, map) :: {:ok, ComplexServerEventType} | {:error, Ecto.Changeset}
  def update_complex_server_event_type(%ComplexServerEventType{} = complex_server_event_type, attrs) do
    complex_server_event_type
    |> ComplexServerEventType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a complex_server_event_type.

  ## Examples

      iex> delete_complex_server_event_type(complex_server_event_type)
      {:ok, %ComplexServerEventType{}}

      iex> delete_complex_server_event_type(complex_server_event_type)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_complex_server_event_type(ComplexServerEventType) :: {:ok, ComplexServerEventType} | {:error, Ecto.Changeset}
  def delete_complex_server_event_type(%ComplexServerEventType{} = complex_server_event_type) do
    Repo.delete(complex_server_event_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking complex_server_event_type changes.

  ## Examples

      iex> change_complex_server_event_type(complex_server_event_type)
      %Ecto.Changeset{data: %ComplexServerEventType{}}

  """
  @spec change_complex_server_event_type(ComplexServerEventType) :: Ecto.Changeset
  @spec change_complex_server_event_type(ComplexServerEventType, map) :: Ecto.Changeset
  def change_complex_server_event_type(%ComplexServerEventType{} = complex_server_event_type, attrs \\ %{}) do
    ComplexServerEventType.changeset(complex_server_event_type, attrs)
  end
end
