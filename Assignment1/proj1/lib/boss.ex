defmodule Proj1.Boss do
  use GenServer
  #      def handle_call({:check,value},_from,state) do
  #          ref = check(value)
  #          {:reply, ref, state}
  #     end

  def handle_call(:get, _, state), do: {:reply, state, state}

  @timeout 100_000_000
  def await(pid), do: GenServer.call(pid, :get, @timeout)

  def handle_cast({:boss, list}, state) do
    IO.puts("I am the Boss")
    ref = Proj1.VampireNumber.start(list)
    {:noreply, [ref| state]}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(queue) do
    {:ok, queue}
  end
end
