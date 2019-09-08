defmodule Proj1 do
  @moduledoc """
  Documentation for Proj1.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Proj1.hello()
      :world

  """
  def hello do
    :world
  end

  def process_bunch(list) do
    {:ok, pid} = Proj1.GenericServer.start_link()
    # children = [
    #        %{
    #                id: VampireNumber,
    #                start: {VampireNumber, :start_link, []}
    #        }
    # ]
    # {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)
    # Proj1.SuperVisor.count_children(pid)
    GenServer.cast(pid, {:check, list})
    pid
  end

  def start(num1, num2) do
    bunch_size = 2000
    bunch = Enum.chunk_every(num1..num2, bunch_size)
    pids = Enum.map(bunch, fn x -> process_bunch(x) end)
    Enum.each(pids, fn x -> Proj1.GenericServer.await(x) end)
  end
end

[arg1, arg2] = System.argv()
# VampireNumber.start(100000, 200000)
{number1, ""} = Integer.parse(arg1)
{number2, ""} = Integer.parse(arg2)
Proj1.start(number1, number2)
