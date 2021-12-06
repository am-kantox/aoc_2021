defmodule AoC_2021.Lanternfish.Static do
  @moduledoc """
  Lanternfish simulation (single process)
  """

  use GenServer

  def start_link(input),
    do: GenServer.start_link(__MODULE__, input, name: Lanternfisher)

  @impl GenServer
  def init(input), do: {:ok, reshape(input)}

  @spec tick :: :ok
  def tick, do: GenServer.cast(Lanternfisher, :tick)

  @spec count :: non_neg_integer()
  def count, do: GenServer.call(Lanternfisher, :count)

  @timer 6
  @timer_first 8

  @impl GenServer
  def handle_cast(:tick, state) do
    new = Map.get(state, 0, 0)

    result =
      @timer_first..0//-1
      |> Enum.reduce({state, nil}, fn
        @timer_first, {acc, nil} ->
          {Map.put(acc, @timer_first, new), Map.get(acc, @timer_first, 0)}

        @timer, {acc, count} ->
          {Map.put(acc, @timer, new + count), Map.get(acc, @timer, 0)}

        i, {acc, count} ->
          {Map.put(acc, i, count), Map.get(acc, i, 0)}
      end)
      |> elem(0)

    {:noreply, result}
  end

  @impl GenServer
  def handle_call(:count, _from, state), do: {:reply, state |> Map.values() |> Enum.sum(), state}

  defp reshape(list),
    do: Enum.reduce(list, %{}, &Map.update(&2, &1, 1, fn i -> i + 1 end))
end
