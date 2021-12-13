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

  def count(%__MODULE__{rows: rows, cols: cols} = data, checker) when is_function(checker, 1) do
    for r <- 0..(rows - 1), c <- 0..(cols - 1), reduce: 0 do
      acc ->
        if checker.(get(data, {r, c})) do
          acc + 1
        else
          acc
        end
    end
  end

  def count(%__MODULE__{} = data, checker),
    do: count(data, &(&1 == checker))

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

  @spec transpose(t(), :vertical | :horizontal | :diagonal) :: t()
  def transpose(%__MODULE__{rows: rows, cols: cols} = data, :vertical) do
    for r <- 0..(rows - 1),
        c <- 0..(cols - 1),
        reduce: new(rows, cols),
        do: (acc -> set(acc, {rows - 1 - r, c}, get(data, {r, c})))
  end

  def transpose(%__MODULE__{rows: rows, cols: cols} = data, :horizontal) do
    for r <- 0..(rows - 1),
        c <- 0..(cols - 1),
        reduce: new(rows, cols),
        do: (acc -> set(acc, {r, cols - 1 - c}, get(data, {r, c})))
  end

  def transpose(%__MODULE__{rows: rows, cols: cols} = data, :diagonal) do
    for r <- 0..(rows - 1),
        c <- 0..(cols - 1),
        reduce: new(cols, rows),
        do: (acc -> set(acc, {c, r}, get(data, {r, c})))
  end

  def fragment(%__MODULE__{} = data, rows_range, cols_range) do
    [rr_size, cr_size] = Enum.map([rows_range, cols_range], &Range.size/1)

    for r <- 0..(rr_size - 1),
        c <- 0..(cr_size - 1),
        reduce: new(rr_size, cr_size),
        do: (acc -> set(acc, {r, c}, get(data, {r + rows_range.first, c + cols_range.first})))
  end

  @spec fold(t(), {boolean(), non_neg_integer()}, (any(), any() -> any())) :: t()
  def fold(%__MODULE__{rows: rows, cols: cols} = data, {false, num}, merge_fun) do
    top_rows = num
    bottom_rows = rows - num - 1
    f_rows = Enum.max([top_rows, bottom_rows])
    folded = new(f_rows, cols)

    folded =
      cond do
        top_rows > bottom_rows ->
          for r <- 0..(top_rows - bottom_rows),
              c <- 0..(cols - 1),
              reduce: folded,
              do: (acc -> set(acc, {r, c}, get(data, {r, c})))

        top_rows < bottom_rows ->
          for r <- 0..(bottom_rows - top_rows),
              c <- 0..(cols - 1),
              reduce: folded,
              do: (acc -> set(acc, {r, c}, get(data, {rows - r - 1, c})))

        true ->
          folded
      end

    for r <- abs(top_rows - bottom_rows)..(f_rows - 1),
        c <- 0..(cols - 1),
        reduce: folded do
      acc ->
        {r1, r2} =
          if top_rows - bottom_rows > 0 do
            {r + top_rows - bottom_rows, rows - r - 1}
          else
            {r, rows - top_rows + bottom_rows - r - 1}
          end

        set(acc, {r, c}, merge_fun.(get(data, {r1, c}), get(data, {r2, c})))
    end
  end

  def fold(%__MODULE__{} = data, {true, num}, merge_fun) do
    data
    |> transpose(:diagonal)
    |> fold({false, num}, merge_fun)
    |> transpose(:diagonal)
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
