defmodule AoC_2021.Lanternfish do
  @moduledoc """
  Lanternfish simulation
  """

  defmodule Sup do
    @moduledoc """
    Lanternfish supervisor
    """
    use DynamicSupervisor

    def start_link,
      do: DynamicSupervisor.start_link(__MODULE__, nil, name: Lanternfisher)

    @impl DynamicSupervisor
    def init(nil), do: DynamicSupervisor.init(strategy: :one_for_one)

    @spec launch([pos_integer()]) :: :ok
    def launch(timers),
      do:
        Enum.each(
          timers,
          &DynamicSupervisor.start_child(Lanternfisher, {AoC_2021.Lanternfish, &1})
        )

    @spec tick :: :ok
    def tick do
      Lanternfisher
      |> DynamicSupervisor.which_children()
      |> Enum.each(fn {_, pid, :worker, _} -> AoC_2021.Lanternfish.tick(pid) end)
    end

    @spec count :: non_neg_integer()
    def count do
      Lanternfisher
      |> DynamicSupervisor.count_children()
      |> Map.get(:active, 0)
    end
  end

  use GenServer

  @default_internal_timer 6

  @spec start_link(non_neg_integer()) :: GenServer.on_start()
  def start_link(internal_timer \\ 0) do
    internal_timer =
      case internal_timer do
        0 -> @default_internal_timer + 2
        i when is_integer(i) and i > 0 -> i
      end

    GenServer.start_link(__MODULE__, %{internal_timer: internal_timer})
  end

  @impl GenServer
  def init(init_arg), do: {:ok, init_arg}

  def tick(pid), do: GenServer.call(pid, :tick)

  @impl GenServer
  def handle_call(:tick, _from, %{internal_timer: 0}) do
    DynamicSupervisor.start_child(Lanternfisher, {AoC_2021.Lanternfish, 0})
    {:reply, :child_started, %{internal_timer: @default_internal_timer}}
  end

  def handle_call(:tick, _from, %{internal_timer: internal_timer}),
    do: {:reply, :noop, %{internal_timer: internal_timer - 1}}
end
