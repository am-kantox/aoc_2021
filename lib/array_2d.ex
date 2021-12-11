defmodule AoC_2021.Array2DInt do
  @moduledoc """
  Two-dimentional integer array
  """

  defstruct [:array, :rows, :cols]

  @type t :: %{
          __struct__: __MODULE__,
          array: :array.array(integer()),
          rows: pos_integer(),
          cols: pos_integer()
        }

  @spec new(binary() | list()) :: t()
  def new(file) when is_binary(file) do
    file
    |> File.stream!()
    |> Stream.map(fn line ->
      line
      |> String.trim_trailing(<<?\n>>)
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.to_list()
    |> new()
  end

  def new([h | _] = list) when is_list(list) do
    rows = length(list)
    cols = length(h)

    list
    |> Enum.with_index()
    |> Enum.reduce(new(rows, cols), fn {row, ri}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {value, ci}, acc ->
        set(acc, {ri, ci}, value)
      end)
    end)
  end

  @spec new(pos_integer(), pos_integer()) :: t()
  def new(rows, cols) do
    row = :array.new(cols)
    array = Enum.reduce(0..(rows - 1), :array.new(rows), &:array.set(&1, row, &2))

    struct!(__MODULE__,
      array: array,
      rows: :array.size(array),
      cols: :array.size(:array.get(0, array))
    )
  end

  def get(data, row_col, default \\ nil)

  def get(%__MODULE__{array: array, rows: rows, cols: cols}, {row, col}, default)
      when row in 0..(rows - 1) and col in 0..(cols - 1) do
    case :array.get(col, :array.get(row, array)) do
      :undefined -> default
      value -> value
    end
  end

  def get(%__MODULE__{}, {_, _}, default), do: default

  def set(%__MODULE__{array: array} = data, {row, col}, value) do
    new_row = :array.set(col, value, :array.get(row, array))
    %__MODULE__{data | array: :array.set(row, new_row, array)}
  end

  def inc(%__MODULE__{rows: rows, cols: cols} = data, value \\ 1) do
    for r <- 0..(rows - 1),
        c <- 0..(cols - 1),
        reduce: data,
        do:
          (acc ->
             update_in(acc, [{r, c}], fn
               nil -> :undefined
               v -> v + value
             end))
  end

  def fill(%__MODULE__{rows: rows, cols: cols} = data, filler) do
    for r <- 0..(rows - 1),
        c <- 0..(cols - 1),
        reduce: data,
        do: (acc -> set(acc, {r, c}, filler))
  end

  def all?(%__MODULE__{} = data, value \\ :undefined) do
    data == fill(data, value)
  end

  def adjacent(%__MODULE__{} = data, {row, col}, diagonals? \\ false) do
    for r <- (row - 1)..(row + 1),
        c <- (col - 1)..(col + 1),
        {r, c} != {row, col},
        diagonals? || r == row or c == col do
      {{r, c}, get(data, {r, c})}
    end
    |> Enum.reject(&match?({_, nil}, &1))
  end

  def low_points(%__MODULE__{rows: rows, cols: cols} = data) do
    for r <- 0..(rows - 1), c <- 0..(cols - 1) do
      v = get(data, {r, c})

      adjs = adjacent(data, {r, c})

      if Enum.all?(adjs, fn {_, value} -> value > v end),
        do: {{{r, c}, v}, adjs},
        else: nil
    end
    |> Enum.reject(&is_nil/1)
  end

  @behaviour Access

  @impl Access
  def fetch(%__MODULE__{} = data, {row, col}) do
    case get(data, {row, col}) do
      nil -> :error
      value -> {:ok, value}
    end
  end

  @impl Access
  def get_and_update(%__MODULE__{} = data, {row, col}, fun) do
    value = get(data, {row, col})

    case fun.(value) do
      :pop ->
        pop(data, {row, col})

      {get_value, update_value} ->
        {get_value, set(data, {row, col}, update_value)}
    end
  end

  @impl Access
  def pop(%__MODULE__{} = data, {row, col}) do
    {get(data, {row, col}), set(data, {row, col}, :undefined)}
  end
end
