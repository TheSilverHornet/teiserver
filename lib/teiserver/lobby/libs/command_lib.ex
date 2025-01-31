defmodule Teiserver.Lobby.CommandLib do
  @moduledoc """

  """

  alias Teiserver.{Account, Battle}
  alias Teiserver.Lobby.ChatLib
  alias Teiserver.Data.Types, as: T

  @spec handle_command(T.lobby_server_state, T.userid, String.t) :: T.lobby_server_state
  def handle_command(state, userid, message) do
    [name | args] = String.split(message, " ")
    name = String.downcase(name)

    command = %{
      raw: message,
      name: name,
      args: args,
      silent: false,
      error: nil,
      userid: userid
    }

    module = get_command_module(name)
    module.execute(state, command)
  end

  @spec get_command_module(String.t) :: module
  def get_command_module(name) do
    Central.store_get(:lobby_command_cache, name) ||
      Central.store_get(:lobby_command_cache, "no_command")
  end

  def cache_lobby_commands() do
    {:ok, module_list} = :application.get_key(:central, :modules)
    lookup = module_list
      |> Enum.filter(fn m ->
        m |> Module.split |> Enum.take(3) == ["Teiserver", "Lobby", "Commands"]
      end)
      |> Enum.filter(fn m ->
        Code.ensure_loaded(m)
        function_exported?(m, :name, 0) && function_exported?(m, :execute, 2)
      end)
      |> Enum.reduce(%{}, fn module, acc ->
        Map.put(acc, module.name(), module)
      end)

    old = Central.store_get(:lobby_command_cache, "all") || []

    # Store all keys, we'll use it later for removing old ones
    Central.store_put(:lobby_command_cache, "all", Map.keys(lookup))

    # Now store our lookups
    lookup
    |> Enum.each(fn {key, func} ->
      Central.store_put(:lobby_command_cache, key, func)
    end)

    # Special case
    no_command_module = Teiserver.Lobby.Commands.NoCommand
    Central.store_put(:lobby_command_cache, "no_command", no_command_module)

    # Delete out-dated keys
    old
    |> Enum.reject(fn old_key ->
      Map.has_key?(lookup, old_key)
    end)
    |> Enum.each(fn old_key ->
      Central.store_delete(:lobby_command_cache, old_key)
    end)

    :ok
  end

  @spec say_command(Map.t(), Map.t()) :: Map.t()
  def say_command(cmd = %{silent: true}, state), do: log_command(cmd, state)

  def say_command(cmd, lobby_id) do
    message = "$ " <> command_as_message(cmd)
    Battle.say(cmd.userid, message, lobby_id)
  end

  @spec log_command(map, T.lobby_id) :: any
  def log_command(cmd, lobby_id) do
    message = "$ " <> command_as_message(cmd)
    sender = Account.get_user_by_id(cmd.userid)
    ChatLib.persist_message(sender, message, lobby_id, :say)
  end

  @spec command_as_message(Map.t()) :: String.t()
  def command_as_message(cmd) do
    remaining = if Map.get(cmd, :remaining), do: " #{cmd.remaining}", else: ""
    error = if Map.get(cmd, :error), do: " Error: #{cmd.error}", else: ""

    "#{cmd.name}#{remaining}#{error}"
    |> String.trim()
  end
end
