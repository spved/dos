defmodule Proj1.VampireNumber do
  use Agent, restart: :temporary

  def start(list) do
    bunch_size = 2000
    bunch = Enum.chunk_every(list, bunch_size)
    pids = Enum.map(bunch, fn x -> process_bunch(x) end)
    Enum.each(pids, fn x -> Proj1.Worker.await(x) end)
    System.stop(0)
  end

  def process(list) do
    # Enum.each(list, &VampireNumber.check/1)
    Enum.each(list, fn n ->
      case check(n) do
        [] ->
          nil

        vf ->
          printing(vf, n)
      end
    end)
  end

  def check(n) do
    if rem(length(to_charlist(n)), 2) == 1 do
      []
    else
      half = div(length(to_charlist(n)), 2)
      sorted = Enum.sort(String.codepoints("#{n}"))

      Enum.filter(check_flangs(n), fn {a, b} ->
        length(to_charlist(a)) == half && length(to_charlist(b)) == half &&
          Enum.count([a, b], fn x -> rem(x, 10) == 0 end) != 2 &&
          Enum.sort(String.codepoints("#{a}#{b}")) == sorted
      end)
    end
  end

  def check_flangs(current_number) do
    part1 = trunc(current_number / :math.pow(10, div(length(to_charlist(current_number)), 2)))
    part2 = :math.sqrt(current_number) |> round
    for k <- part1..part2, rem(current_number, k) == 0, do: {k, div(current_number, k)}
  end

  def printing(vf, n) do
    input = inspect(vf)
    output_to_string = Kernel.inspect(input)
    pattern = :binary.compile_pattern(["{", "}", "[", "]", ",", "  "])
    output_replace_brackets = String.replace(output_to_string, pattern, "")
    output = String.replace(~s(#{output_replace_brackets}), ~s("), "")
    IO.puts "#{n} \t#{output}"
    output
  end

  def process_bunch(list) do
    {:ok, pid} = Proj1.Worker.start_link()
    # children = [
    #        %{
    #                id: VampireNumber,
    #                start: {VampireNumber, :start_link, []}
    #        }
    # ]
    # {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)
    # Proj1.SuperVisor.count_children(pid)
    GenServer.cast(pid, {:worker, list})
    pid
  end



end
