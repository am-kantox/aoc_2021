defmodule AoC_2021 do
  @moduledoc "Solutions"

  alias AoC_2021.Array2DInt, as: Arr2D

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

  @doc """
  Bingo game

  ## Examples

      iex> AoC_2021.d4_bingo("d4_input")
      74320
  """
  @spec d4_bingo(binary()) :: pos_integer()
  def d4_bingo(file) do
    [numbers | boards] =
      file
      |> File.read!()
      |> String.split("\n\n")

    AoC_2021.BingoBoard.run(boards, numbers)
  end

  @doc """
  Bingo game (we are losing)

  ## Examples

      iex> AoC_2021.d4_bingo_lose("d4_input")
      17884
  """
  @spec d4_bingo_lose(binary()) :: pos_integer()
  def d4_bingo_lose(file) do
    [numbers | boards] =
      file
      |> File.read!()
      |> String.split("\n\n")

    AoC_2021.BingoBoard.run_to_lose(boards, numbers)
  end

  alias AoC_2021.CrossingBoard, as: B

  @doc """
  Hydrothermal venture

  ## Examples

      iex> AoC_2021.d5_crosses("d5_input")
      5169

      iex> AoC_2021.d5_crosses("d5_input", true)
      22083
  """
  @spec d5_crosses(binary()) :: non_neg_integer()
  def d5_crosses(file, diags? \\ false) do
    file
    |> File.stream!()
    |> Stream.map(&Regex.scan(~r/\d+/, &1))
    |> Stream.map(&List.flatten/1)
    |> Stream.map(fn row -> Enum.map(row, &String.to_integer/1) end)
    |> Enum.reduce(B.create(1000), fn
      [x, y1, x, y2], acc -> B.succ(acc, {:row, x, {y1, y2}})
      [x1, y, x2, y], acc -> B.succ(acc, {:col, y, {x1, x2}})
      [x1, y1, x2, y2], acc when diags? -> B.succ(acc, {:dia, {x1, y1}, {x2, y2}})
      _, acc -> acc
    end)
    |> B.total()
  end

  alias AoC_2021.Lanternfish.Static, as: L

  @doc """
  Lanternfish

  ## Examples

      iex> AoC_2021.d6_population("d6_input", 18)
      1_593
      iex> AoC_2021.d6_population("d6_input", 80)
      354_564
      iex> AoC_2021.d6_population("d6_input", 256)
      1_609_058_859_115
  """
  @spec d6_population(binary(), pos_integer()) :: non_neg_integer()
  def d6_population(file, days) do
    {:ok, pid} =
      file
      |> File.read!()
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> L.start_link()

    Enum.each(1..days, fn _ -> L.tick() end)

    L.count()
    |> tap(fn _ -> GenServer.stop(pid) end)
  end

  @doc """
  Crab adjustement

  ## Examples

      iex> AoC_2021.d7_adjust("d7_input", true)
      339321

      iex> AoC_2021.d7_adjust("d7_input", false)
      95476244
  """
  @spec d7_adjust(binary(), boolean()) :: non_neg_integer()
  def d7_adjust(file, const_fuel_consumption) do
    input =
      file
      |> File.read!()
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    steps = fn arr ->
      if const_fuel_consumption do
        fn i -> Enum.reduce(arr, 0, &(&2 + abs(&1 - i))) end
      else
        fn i ->
          arr
          |> Enum.map(fn
            e ->
              diff = abs(e - i)
              round((diff + 1) * diff / 2)
          end)
          |> Enum.sum()
        end
      end
    end

    {min, max} = Enum.min_max(input)

    result = Enum.min_by(min..max, steps.(input))
    steps.(input).(result)
  end

  @doc """
  Segments rearranging

  ## Examples

      iex> AoC_2021.d8_segments("d8_input", :shorties)
      365

      iex> AoC_2021.d8_segments("d8_input", :full)
      975706

  """
  @spec d8_segments(binary(), :shorties | :full) :: non_neg_integer()
  def d8_segments(file, :shorties) do
    file
    |> File.stream!()
    |> Stream.map(&String.split(&1, "|", trim: true))
    |> Stream.map(fn [_, outputs] ->
      outputs
      |> String.split()
      |> Enum.reduce(0, fn
        <<_::8*2>>, acc -> acc + 1
        <<_::8*3>>, acc -> acc + 1
        <<_::8*4>>, acc -> acc + 1
        <<_::8*7>>, acc -> acc + 1
        _other, acc -> acc
      end)
    end)
    |> Enum.sum()
  end

  def d8_segments(file, :full) do
    file
    |> File.stream!()
    |> Stream.map(&String.split(&1, "|", trim: true))
    |> Stream.map(fn [inputs, outputs] ->
      Enum.map([inputs, outputs], fn strings ->
        strings |> String.split() |> Enum.map(&to_charlist/1) |> Enum.map(&Enum.sort/1)
      end)
    end)
    |> Enum.map(fn [input, output] ->
      one = Enum.find(input, &match?([_, _], &1))
      seven = Enum.find(input, &match?([_, _, _], &1))
      four = Enum.find(input, &match?([_, _, _, _], &1))
      eight = Enum.find(input, &match?([_, _, _, _, _, _, _], &1))

      zero_six_nine = Enum.filter(input, &match?([_, _, _, _, _, _], &1))
      {[six], zero_nine} = Enum.split_with(zero_six_nine, &match?([_, _, _, _], &1 -- seven))
      {[nine], [zero]} = Enum.split_with(zero_nine, &Enum.all?(four, fn c -> c in &1 end))

      two_three_five = Enum.filter(input, &match?([_, _, _, _, _], &1))
      {[three], two_five} = Enum.split_with(two_three_five, &match?([_, _], &1 -- seven))
      {[five], [two]} = Enum.split_with(two_five, &Enum.all?(&1, fn c -> c in nine end))

      map = %{
        zero => 0,
        one => 1,
        two => 2,
        three => 3,
        four => 4,
        five => 5,
        six => 6,
        seven => 7,
        eight => 8,
        nine => 9
      }

      output
      |> Enum.reverse()
      |> Enum.with_index(0)
      |> Enum.reduce(0, fn {digit, idx}, acc ->
        map[digit] * :math.pow(10, idx) + acc
      end)
    end)
    |> Enum.sum()
    |> round()
  end

  @doc """
  Low levels

  ## Examples

      iex> AoC_2021.d9_low_points("d9_input", :low_points)
      560

      iex> AoC_2021.d9_low_points("d9_input", :basins)
      483664

  """
  @spec d9_low_points(binary(), :low_points | :full) :: non_neg_integer()
  def d9_low_points(file, :low_points) do
    file
    |> Arr2D.new()
    |> Arr2D.low_points()
    |> Enum.reduce(0, fn {{{_, _}, v}, _}, acc -> acc + v + 1 end)
  end

  def d9_low_points(file, :basins) do
    data = Arr2D.new(file)

    data
    |> Arr2D.low_points()
    |> Enum.map(&d9_step(&1, data))
    |> Enum.map(&MapSet.size/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.reduce(&Kernel.*/2)
  end

  defp d9_step(input, acc \\ [], data)

  defp d9_step(input, acc, data) when is_list(acc),
    do: d9_step(input, MapSet.new(acc), data)

  defp d9_step({{{_, _}, v}, adjs} = elem, acc, data) do
    if MapSet.member?(acc, elem) do
      acc
    else
      acc = MapSet.put(acc, elem)

      next = v + 1

      news =
        adjs
        |> Stream.reject(&match?({{_, _}, 9}, &1))
        |> Stream.filter(&match?({{_, _}, ^next}, &1))
        |> Stream.map(fn {{r, c}, v} ->
          {{{r, c}, v}, Arr2D.adjacent(data, {r, c})}
        end)
        |> MapSet.new()
        |> MapSet.difference(acc)

      if MapSet.size(news) > 0 do
        news
        |> Enum.map(&d9_step(&1, acc, data))
        |> Enum.reduce(&MapSet.union/2)
      else
        acc
      end
    end
  end

  @scores %{
    corrupted: %{
      ?) => 3,
      ?] => 57,
      ?} => 1197,
      ?> => 25137
    },
    incomplete: %{
      ?( => 1,
      ?[ => 2,
      ?{ => 3,
      ?< => 4
    }
  }
  @pairs %{
    ?( => ?),
    ?[ => ?],
    ?{ => ?},
    ?< => ?>
  }
  @doc """
  Corrupted chunks

  ## Examples

      iex> AoC_2021.d10_cc("d10_input", :corrupted)
      243939

      iex> AoC_2021.d10_cc("d10_input", :incomplete)
      2421222841

  """
  @spec d10_cc(binary(), :corrupted | :incomplete) :: non_neg_integer()
  def d10_cc(file, type) when type in [:corrupted, :incomplete] do
    outcome =
      file
      |> File.stream!()
      |> Stream.map(&d10_parse/1)
      |> Enum.reduce([], fn
        {^type, char}, acc -> d10_reducer({type, char}, acc)
        _, acc -> acc
      end)

    case type do
      :corrupted ->
        Enum.sum(outcome)

      :incomplete ->
        with c <- Enum.count(outcome), do: outcome |> Enum.sort() |> Enum.at(div(c, 2))
    end
  end

  defp d10_reducer({:corrupted, char}, acc) do
    [@scores[:corrupted][char] | acc]
  end

  defp d10_reducer({:incomplete, chars}, acc) do
    [Enum.reduce(chars, 0, &(&2 * 5 + @scores[:incomplete][&1])) | acc]
  end

  def d10_parse(line, acc \\ [])
  def d10_parse("", acc), do: {:incomplete, acc}

  Enum.each(@pairs, fn {open, close} ->
    def d10_parse(<<unquote(open), rest::binary>>, acc),
      do: d10_parse(rest, [unquote(open) | acc])

    def d10_parse(<<unquote(close), rest::binary>>, [unquote(open) | acc]),
      do: d10_parse(rest, acc)

    def d10_parse(<<unquote(close), _::binary>>, _), do: {:corrupted, unquote(close)}
  end)

  def d10_parse(<<_, rest::binary>>, acc),
    do: d10_parse(rest, acc)

  @doc """
  Low levels

  ## Examples

      iex> AoC_2021.d11_dumbos("d11_input", :flashes)
      1723

      iex> AoC_2021.d11_dumbos("d11_input", :splashes)
      327
  """
  @spec d11_dumbos(binary(), :flashes | :splashes) :: non_neg_integer()
  def d11_dumbos(file, type) when type in ~w|flashes splashes|a do
    file
    |> Arr2D.new()
    |> d11_steps(type)
    |> elem(1)
  end

  @max_steps 100

  defp d11_steps(arr, type, step \\ 1, flashes \\ 0) do
    {arr, fs} = d11_step(Arr2D.inc(arr))

    cond do
      type == :flashes && step == @max_steps -> {arr, flashes + fs}
      type == :splashes && Arr2D.all?(arr, 0) -> {arr, step}
      true -> d11_steps(arr, type, step + 1, flashes + fs)
    end
  end

  defp d11_step(%Arr2D{rows: rows, cols: cols} = arr, flashes \\ 0) do
    {arr, fs} =
      for r <- 0..(rows - 1),
          c <- 0..(cols - 1),
          reduce: {arr, 0} do
        {acc, f} ->
          case Arr2D.get(acc, {r, c}) do
            nil ->
              {acc, f}

            v when v <= 9 ->
              {acc, f}

            _ ->
              acc = put_in(acc, [{r, c}], :undefined)

              acc =
                acc
                |> Arr2D.adjacent({r, c}, true)
                |> Enum.reduce(
                  acc,
                  &update_in(&2, [elem(&1, 0)], fn
                    nil -> :undefined
                    v -> v + 1
                  end)
                )

              {acc, f + 1}
          end
      end

    if fs == 0 do
      arr =
        for r <- 0..(arr.rows - 1),
            c <- 0..(arr.cols - 1),
            reduce: arr,
            do:
              (acc ->
                 update_in(acc, [{r, c}], fn
                   nil -> 0
                   v -> v
                 end))

      {arr, flashes}
    else
      d11_step(arr, fs + flashes)
    end
  end
end
