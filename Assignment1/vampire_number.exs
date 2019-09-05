defmodule VampireNumber do
     use GenServer
 #      def handle_call({:check,value},_from,state) do
 #          ref = check(value)
 #          {:reply, ref, state}
 #     end
 
       def handle_call(:get, _, state), do: {:reply, state, state}

       def await(pid), do: GenServer.call(pid, :get)

       def handle_cast({:check, list},state) do
           ref = process(list)
           {:noreply, [ref| state]}
       end
	
	def start_link() do
        	GenServer.start_link(__MODULE__, :queue.new())
       end
       def init(queue) do
        {:ok, queue}
       end

	#function to check flangs
       def check_flangs(list,current_number,table) do
          num_length = length(list)/2
          [p|q] = Enum.chunk_every(list, Kernel.trunc(num_length))
          first = Integer.undigits(p)
	  second = Integer.undigits(List.flatten(q))
               
          if current_number == first * second do
             n1  = Integer.undigits(List.flatten(q))
             n2 =  Integer.undigits(p)
             [{_, bucket}] = :ets.lookup(table, current_number)                   
             bucket = bucket |> Kernel.<>(Integer.to_string(n1))
             bucket = bucket |> Kernel.<>(" ")
             bucket = bucket |> Kernel.<>(Integer.to_string(n2))
             bucket = bucket |> Kernel.<>(" ")
             :ets.insert(table,{current_number,bucket})
          end
	end

#function to check all possible pairs
#TO DO: can use Enum.each instead
def parse_list([head | tail], current_number, table) do
check_flangs(List.flatten(head), current_number, table)
parse_list(tail, current_number, table)
end

def parse_list([],_,_), do: nil

#function to find permutation of given number
        def get_permutation([]), do: [[]]
        def get_permutation(list) do
                for elem <- list, rest <- get_permutation(list--[elem]), do: [elem|rest]
        end

        def check(current_number) do
          cur_num_list = Integer.digits(current_number)
       	 if rem(length(cur_num_list),2) == 0 do
    	     possible_flangs_list = Enum.uniq(get_permutation(cur_num_list))
             table = :ets.new(:buckets_registry, [:set,:protected])
             :ets.insert(table,{current_number,""})
    	     parse_list(possible_flangs_list, current_number,table)
             [{_, bucket}] = :ets.lookup(table, current_number)
             ls = Enum.uniq(String.split(bucket))
             output = Enum.reverse(ls)
             if Enum.count(output)!=0 do
                output = Enum.join(output, " ")
                output = " " |> Kernel.<> output
                output = Integer.to_string(current_number) |> Kernel.<>output
                IO.puts output
             end	         
          end
        end

        def process(list) do
                Enum.each(list, &VampireNumber.check/1)
        end
 
	def process_bunch(list) do
	   {:ok,pid} = VampireNumber.start_link()
           GenServer.cast(pid,{:check,list})
           VampireNumber.await(pid)
	end

        def start(num1, num2) do
	   bunch_size=1000
	   bunch = Enum.chunk_every(num1..num2, bunch_size)
	   Enum.each(bunch, &process_bunch/1)
	end
       
end

#IO.puts("start")
{current_number1, _ } = Integer.parse(IO.gets("Enter Number1 : "))
{current_number2, _ } = Integer.parse(IO.gets("Enter Number2 : "))

#Enum.each(current_number1..current_number2, &VampireNumber.check1/1)
VampireNumber.start(current_number1, current_number2)

