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

  @destination_acc %{h: 0, v: 0, aim: 0}
  @type aimed() :: boolean()

  @doc """
  Calculates the destination

  ## Example

      iex> AoC_2021.d2_destination("d2_input", false)
      1507611

      iex> AoC_2021.d2_destination("d2_input", true)
      1880593125
  """
  @spec d2_destination(binary(), aimed()) :: non_neg_integer()
  def d2_destination(file, aimed?) do
    reducer = if aimed?, do: &d2_destination_aimed_reducer/2, else: &d2_destination_reducer/2

    file
    |> File.stream!()
    |> Enum.reduce(@destination_acc, reducer)
    |> Map.take([:h, :v])
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

  defp d2_destination_aimed_reducer("forward " <> value, acc) do
    x = value |> String.trim() |> String.to_integer()
    %{acc | h: acc.h + x, v: acc.v + x * acc.aim}
  end

  defp d2_destination_aimed_reducer("down " <> value, acc),
    do: %{acc | aim: acc.aim + (value |> String.trim() |> String.to_integer())}

  defp d2_destination_aimed_reducer("up " <> value, acc),
    do: %{acc | aim: acc.aim - (value |> String.trim() |> String.to_integer())}

  defp d2_destination_aimed_reducer(_, acc), do: acc

  @doc """
  Diagnostics

  ## Examples

      iex> AoC_2021.d3_diagnostics("d3_input")
      1836 * 2259
  """
  @spec d3_diagnostics(binary()) :: non_neg_integer()
  def d3_diagnostics(file) do
    {count, counts} =
      file
      |> File.stream!()
      |> Enum.reduce({0, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, fn
        <<c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, _::binary>>,
        {count, [i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12]} ->
          acc =
            [c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12]
            |> Enum.zip([i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12])
            |> Enum.map(fn
              {?1, i} -> i + 1
              {?0, i} -> i
            end)

          {count + 1, acc}
      end)

    result = Enum.map(counts, fn i -> if i / count > 0.5, do: ?1, else: ?0 end)
    coresult = Enum.map(result, fn i -> if i == ?0, do: ?1, else: ?0 end)

    [result, coresult]
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.to_integer(&1, 2))
    |> Enum.reduce(&Kernel.*/2)
  end

  @lsr_acc %{?0 => [], ?1 => []}
  @doc """
  Diagnostics

  ## Examples

      iex> AoC_2021.d3_life_support_rating("d3_input")
      1427 * 2502
  """
  @spec d3_life_support_rating(binary()) :: non_neg_integer()
  def d3_life_support_rating(file) do
    input =
      file
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Enum.to_list()

    input = Enum.zip(input, input)

    ogr = d3_reducer(input, &Kernel.</2)
    co2_sr = d3_reducer(input, &Kernel.>=/2)

    ogr * co2_sr
  end

  defp d3_lsr_step_reducer({<<?0, rest::binary>>, value}, %{?0 => zeros, ?1 => ones}),
    do: %{?0 => [{rest, value} | zeros], ?1 => ones}

  defp d3_lsr_step_reducer({<<?1, rest::binary>>, value}, %{?0 => zeros, ?1 => ones}),
    do: %{?0 => zeros, ?1 => [{rest, value} | ones]}

  defp d3_reducer([{_, result}], _), do: String.to_integer(result, 2)

  defp d3_reducer(list, checker) do
    %{?0 => zeros, ?1 => ones} = Enum.reduce(list, @lsr_acc, &d3_lsr_step_reducer/2)

    [zeros, ones]
    |> Enum.map(&Enum.count/1)
    |> Enum.reduce(checker)
    |> if(do: zeros, else: ones)
    |> d3_reducer(checker)
  end
end
