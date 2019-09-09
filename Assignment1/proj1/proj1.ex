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

  def wait() do
    wait()
  end
  def main() do
    [arg1, arg2] = System.argv()
    # VampireNumber.start(100000, 200000)
    {number1, ""} = Integer.parse(arg1)
    {number2, ""} = Integer.parse(arg2)
    #{:ok, pid} = Proj1.Boss.start_link()
    Proj1.SuperVisor.start_link([])
    GenServer.cast(Proj1.Boss, {:boss, number1..number2})
    :sys.get_state(Proj1.Boss)
    #Proj1.Boss.await(Proj1.Boss)
  end

end


Proj1.main()
