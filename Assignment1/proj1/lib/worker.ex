defmodule Proj1.Worker do
  use GenServer
  #      def handle_call({:check,value},_from,state) do
  #          ref = check(value)
  #          {:reply, ref, state}
  #     end

  def handle_call(:get, _, state), do: {:reply, state, state}

  @timeout 100_000_000
  def await(pid), do: GenServer.call(pid, :get, @timeout)

  def handle_cast({:worker, list}, state) do
    # {:ok, pid} = DynamicSuper.start_child(Proj1.VampireNumberSupervisor, Proj1.VampireNumber)
    # ref = Process.monitor:queue.new()
    # refs = Map.put(refs, ref, name)
    # names = Map.put(names, name, pid)
    ref = Proj1.VampireNumber.process(list)
    {:noreply, [ref | state]}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, :queue.new())
  end

  def init(queue) do
    {:ok, queue}
  end
end
