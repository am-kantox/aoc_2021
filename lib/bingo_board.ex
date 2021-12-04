defmodule AoC_2021.BingoBoard do
  @moduledoc """
  Bingo board operations
  """

  @type cell_state :: :empty | :bingo
  @type row :: [{non_neg_integer(), cell_state()}]
  @type board :: [row()]

  @doc """
  Board producer

  ## Examples

      iex> input = ~s|
      ...>   22 13 17 11  0
      ...>   8  2 23  4 24
      ...>   21  9 14 16  7
      ...>   6 10  3 18  5
      ...>   1 12 20 15 19
      ...> |
      iex> input |> AoC_2021.BingoBoard.create() |> hd()
      [{22, :empty}, {13, :empty}, {17, :empty}, {11, :empty}, {0, :empty}]
  """
  @spec create(binary()) :: board()
  def create(input) do
    input
    |> String.split(<<?\n>>, trim: true)
    |> Enum.reject(&(String.trim(&1) == ""))
    |> Enum.map(fn line ->
      line
      |> String.split(<<?\s>>, trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.map(&{&1, :empty})
    end)
  end

  @doc """
  Runs a list of numbers against several boards to find a winner
  """
  @spec run([board() | binary()], binary()) :: non_neg_integer()
  def run([], _), do: 0

  def run([board | _] = boards, numbers) when is_binary(board),
    do: boards |> Enum.map(&create/1) |> run(numbers)

  def run(boards, numbers) do
    numbers
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce_while(boards, fn x, acc ->
      boards = Enum.map(acc, &move(&1, x))
      found = for board <- boards, result when not is_nil(result) <- [check(board)], do: result

      case found do
        [] -> {:cont, boards}
        [value] when is_integer(value) -> {:halt, x * value}
      end
    end)
  end

  @doc """
  Runs a list of numbers against several boards to find a loser
  """
  @spec run_to_lose([board() | binary()], binary()) :: non_neg_integer()
  def run_to_lose([], _), do: 0

  def run_to_lose([board | _] = boards, numbers) when is_binary(board),
    do: boards |> Enum.map(&create/1) |> run_to_lose(numbers)

  def run_to_lose(boards, numbers) do
    numbers
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce_while(boards, fn x, acc ->
      boards = Enum.map(acc, &move(&1, x))

      state = Enum.map(boards, &{check(&1), &1})

      case state do
        [] -> {:halt, :error}
        [{nil, board}] -> {:cont, [board]}
        [{loser, _}] -> {:halt, x * loser}
        many -> {:cont, many |> Enum.filter(&match?({nil, _}, &1)) |> Enum.map(&elem(&1, 1))}
      end
    end)
  end

  @doc """
  Amends the board accoringly to the number yelled

  ## Examples

      iex> input = ~s|
      ...>   22 13 17 11  0
      ...>   8  2 23  4 24
      ...>   21  9 14 16  7
      ...>   6 10  3 18  5
      ...>   1 12 20 15 19
      ...> |
      iex> input |> AoC_2021.BingoBoard.create() |> AoC_2021.BingoBoard.move(17) |> hd()
      [{22, :empty}, {13, :empty}, {17, :bingo}, {11, :empty}, {0, :empty}]
  """
  @spec move(board(), non_neg_integer()) :: board()
  def move(board, num) do
    board
    |> Enum.map(fn row ->
      Enum.map(row, fn
        {^num, _} -> {num, :bingo}
        cell -> cell
      end)
    end)
  end

  @doc """
  Checks the board for winning, returns `0` if no luck and the result if we won

  ## Examples

      iex> input = ~s|
      ...>   14 21 17 24  4
      ...>   10 16 15  9 19
      ...>   18  8 23 26 20
      ...>   22 11 13  6  5
      ...>    2  0 12  3  7
      ...> |
      iex> input |> AoC_2021.BingoBoard.create() |> AoC_2021.BingoBoard.check()
      nil
      iex> input
      ...> |> AoC_2021.BingoBoard.create()
      ...> |> AoC_2021.BingoBoard.move(14)
      ...> |> AoC_2021.BingoBoard.move(21)
      ...> |> AoC_2021.BingoBoard.move(17)
      ...> |> AoC_2021.BingoBoard.move(24)
      ...> |> AoC_2021.BingoBoard.move(4)
      ...> |> AoC_2021.BingoBoard.check()
      245
  """
  @spec check(board()) :: nil | non_neg_integer()
  def check(board) do
    if check_rows(board) or check_rows(transpose(board)) do
      board
      |> List.flatten()
      |> Enum.filter(&match?({_, :empty}, &1))
      |> Enum.map(&elem(&1, 0))
      |> Enum.sum()
    end
  end

  @spec transpose(board()) :: board()
  defp transpose([[] | _]), do: []

  defp transpose(rows) do
    heads = Enum.map(rows, &hd/1)
    tails = Enum.map(rows, &tl/1)
    [heads | transpose(tails)]
  end

  @spec check_rows(board()) :: boolean()
  defp check_rows([]), do: false
  defp check_rows([row | rest]), do: check_row(row) or check_rows(rest)

  @spec check_row(row()) :: boolean()
  defp check_row([{_, :bingo}, {_, :bingo}, {_, :bingo}, {_, :bingo}, {_, :bingo}]), do: true
  defp check_row(_), do: false
end
