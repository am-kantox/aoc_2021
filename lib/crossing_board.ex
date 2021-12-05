defmodule AoC_2021.CrossingBoard do
  @moduledoc """
  Bingo board operations
  """

  @type row :: [non_neg_integer()]
  @type board :: [row()]

  @doc """
  Board producer

  ## Examples

      iex> AoC_2021.CrossingBoard.create(3)
      [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
  """
  @spec create(pos_integer()) :: board()
  def create(size) do
    0
    |> List.duplicate(size)
    |> List.duplicate(size)
  end

  @doc """
  Board increaser

  ## Examples

      iex> 3 |> AoC_2021.CrossingBoard.create() |> AoC_2021.CrossingBoard.succ({:row, 1, {2, 1}})
      [[0, 0, 0], [0, 1, 1], [0, 0, 0]]
      iex> 3 |> AoC_2021.CrossingBoard.create() |> AoC_2021.CrossingBoard.succ({:col, 1, {2, 0}})
      [[0, 1, 0], [0, 1, 0], [0, 1, 0]]
      iex> 3
      ...> |> AoC_2021.CrossingBoard.create()
      ...> |> AoC_2021.CrossingBoard.succ({:col, 1, {2, 0}})
      ...> |> AoC_2021.CrossingBoard.succ({:row, 1, {1, 2}})
      [[0, 1, 0], [0, 2, 1], [0, 1, 0]]
      iex> 3
      ...> |> AoC_2021.CrossingBoard.create()
      ...> |> AoC_2021.CrossingBoard.succ({:dia, {1, 2}, {2, 1}})
      ...> |> AoC_2021.CrossingBoard.succ({:dia, {0, 0}, {2, 2}})
      [[1, 0, 0], [0, 1, 1], [0, 1, 1]]
  """
  @spec succ(
          board(),
          {:row | :col | :dia, non_neg_integer() | {non_neg_integer(), non_neg_integer()},
           {non_neg_integer(), non_neg_integer()}}
        ) ::
          board()
  def succ(board, {:row, row, {c1, c2}}) do
    {c1, c2} = Enum.min_max([c1, c2])

    Enum.reduce(c1..c2, board, fn col, board ->
      update_in(board, [Access.at(row), Access.at(col)], &(&1 + 1))
    end)
  end

  def succ(board, {:col, col, {r1, r2}}) do
    {r1, r2} = Enum.min_max([r1, r2])

    Enum.reduce(r1..r2, board, fn row, board ->
      update_in(board, [Access.at(row), Access.at(col)], &(&1 + 1))
    end)
  end

  def succ(board, {:dia, {r1, c1}, {r2, c2}}) when abs(r1 - r2) == abs(c1 - c2) do
    row_succ = if r1 > r2, do: &Kernel.-/2, else: &Kernel.+/2
    col_succ = if c1 > c2, do: &Kernel.-/2, else: &Kernel.+/2

    Enum.reduce(0..abs(r1 - r2), board, fn idx, board ->
      row = row_succ.(r1, idx)
      col = col_succ.(c1, idx)
      update_in(board, [Access.at(row), Access.at(col)], &(&1 + 1))
    end)
  end

  def succ(board, _), do: board

  @doc """
  Board sum

  ## Examples

      iex> 3 |> AoC_2021.CrossingBoard.create() |> AoC_2021.CrossingBoard.total()
      0
      iex> 3
      ...> |> AoC_2021.CrossingBoard.create()
      ...> |> AoC_2021.CrossingBoard.succ({:col, 1, {2, 0}})
      ...> |> AoC_2021.CrossingBoard.succ({:row, 1, {1, 2}})
      ...> |> AoC_2021.CrossingBoard.succ({:row, 2, {1, 2}})
      ...> |> AoC_2021.CrossingBoard.total()
      2
  """
  @spec total(board()) :: non_neg_integer()
  def total(board),
    do: board |> List.flatten() |> Enum.filter(&(&1 > 1)) |> Enum.count()
end
