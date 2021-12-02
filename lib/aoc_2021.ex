defmodule AoC_2021 do
  @doc """
  Calculates the number of times the input increases

  ## Examples

      iex> AoC_2021.d1_count()
      1292
  """
  @spec d1_count(file :: binary()) :: non_neg_integer()
  def d1_count(file \\ "d1_input") do
    file
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.reduce({0, nil}, fn
      curr, {n, nil} -> {n, curr}
      curr, {n, last} when last < curr -> {n + 1, curr}
      curr, {n, _} -> {n, curr}
    end)
    |> elem(0)
  end

  @doc """
  Calculates the number of times the input increases (with window)

  ## Examples

      iex> AoC_2021.d1_count_window()
      1262
  """
  @spec d1_count_window(file :: binary()) :: non_neg_integer()
  def d1_count_window(file \\ "d1_input") do
    file
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.reduce({0, {nil, nil, nil}}, fn
      curr, {n, {nil, nil, nil}} -> {n, {nil, nil, curr}}
      curr, {n, {nil, nil, p0}} -> {n, {nil, p0, curr}}
      curr, {n, {nil, p1, p0}} -> {n, {p1, p0, curr}}
      curr, {n, {p2, p1, p0}} when p2 < curr -> {n + 1, {p1, p0, curr}}
      curr, {n, {_, p1, p0}} -> {n, {p1, p0, curr}}
    end)
    |> elem(0)
  end

  @destination_acc %{h: 0, v: 0}

  @doc """
  Calculates the destination

  ## Example

      iex> input = ~s|
      ...> forward 5
      ...> down 5
      ...> forward 8
      ...> up 3
      ...> down 8
      ...> forward 2
      ...> |
      iex> AoC_2021.d2_destination(input, false)
      150

      iex> AoC_2021.d2_destination("d2_input", true)
      1507611
  """
  @spec d2_destination(binary(), boolean()) :: non_neg_integer()
  def d2_destination(file \\ "d2_input", file? \\ true)

  def d2_destination(file, true) do
    file
    |> File.stream!()
    |> Enum.reduce(@destination_acc, &d2_destination_reducer/2)
    |> Map.values()
    |> Enum.reduce(&Kernel.*/2)
  end

  def d2_destination(string, false) do
    string
    |> String.split(<<?\n>>)
    |> Enum.map(&String.trim/1)
    |> Enum.reduce(@destination_acc, &d2_destination_reducer/2)
    |> Map.values()
    |> Enum.reduce(&Kernel.*/2)
  end

  defp d2_destination_reducer("forward " <> value, acc),
    do: %{acc | h: acc.h + (value |> String.trim() |> String.to_integer())}

  defp d2_destination_reducer("down " <> value, acc),
    do: %{acc | v: acc.v + (value |> String.trim() |> String.to_integer())}

  defp d2_destination_reducer("up " <> value, acc),
    do: %{acc | v: acc.v - (value |> String.trim() |> String.to_integer())}

  defp d2_destination_reducer(_, acc), do: acc

  @destination_aimed_acc %{h: 0, v: 0, aim: 0}

  @doc """
  Calculates the destination with the aim

  ## Example

      iex> input = ~s|
      ...> forward 5
      ...> down 5
      ...> forward 8
      ...> up 3
      ...> down 8
      ...> forward 2
      ...> |
      iex> AoC_2021.d2_destination_aimed(input, false)
      900

      iex> AoC_2021.d2_destination_aimed("d2_input", true)
      1880593125
  """
  @spec d2_destination_aimed(binary(), boolean()) :: non_neg_integer()
  def d2_destination_aimed(file \\ "d2_input", file? \\ true)

  def d2_destination_aimed(file, true) do
    file
    |> File.stream!()
    |> Enum.reduce(@destination_aimed_acc, &d2_destination_aimed_reducer/2)
    |> Map.take([:h, :v])
    |> Map.values()
    |> Enum.reduce(&Kernel.*/2)
  end

  def d2_destination_aimed(string, false) do
    string
    |> String.split(<<?\n>>)
    |> Enum.map(&String.trim/1)
    |> Enum.reduce(@destination_aimed_acc, &d2_destination_aimed_reducer/2)
    |> Map.take([:h, :v])
    |> Map.values()
    |> Enum.reduce(&Kernel.*/2)
  end

  defp d2_destination_aimed_reducer("forward " <> value, acc) do
    x = value |> String.trim() |> String.to_integer()
    %{acc | h: acc.h + x, v: acc.v + x * acc.aim}
  end

  defp d2_destination_aimed_reducer("down " <> value, acc),
    do: %{acc | aim: acc.aim + (value |> String.trim() |> String.to_integer())}

  defp d2_destination_aimed_reducer("up " <> value, acc),
    do: %{acc | aim: acc.aim - (value |> String.trim() |> String.to_integer())}

  defp d2_destination_aimed_reducer(_, acc), do: acc
end
