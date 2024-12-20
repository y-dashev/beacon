defmodule Beacon.Utils do
  @moduledoc false

  # https://elixirforum.com/t/dynamically-generate-typespecs-from-module-attribute-list/7078/5
  def list_to_typespec(list) when is_list(list) do
    Enum.reduce(list, &{:|, [], [&1, &2]})
  end

  @doc """
  For debugging - convert a quoted expression to string

  Useful to log module body or write a file.

  ## Examples

      # print module body
      quoted |> Beacon.Utils.quoted_to_binary() |> IO.puts()

      # write to a persisted file
      File.write!("module.ex", Beacon.Utils.quoted_to_binary(quoted))

  """
  def quoted_to_binary(ast) do
    ast
    |> Code.quoted_to_algebra()
    |> Inspect.Algebra.format(:infinity)
    |> IO.iodata_to_binary()
  end

  def repo(%{site: site}) do
    repo(site)
  end

  def repo(site) do
    site
    |> Beacon.Config.fetch!()
    |> Map.fetch!(:repo)
  end

  # https://medium.com/very-big-things/towards-maintainable-elixir-the-core-and-the-interface-c267f0da43
  def transact(repo, fun) when is_function(fun) do
    repo.transaction(fn ->
      case fun.() do
        {:ok, result} -> result
        {:error, reason} -> repo.rollback(reason)
        reason -> repo.rollback(reason)
      end
    end)
  end
end
