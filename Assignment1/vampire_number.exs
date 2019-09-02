
defmodule VampireNumber do


	#function to check flangs
        def check_flangs(list,num) do
                num_length = length(list)/2
                [p|q] = Enum.chunk_every(list, Kernel.trunc(num_length))
		first = Integer.undigits(p)
		second = Integer.undigits(List.flatten(q))
                if num == first * second do
			#if first < second do     
			#	output = output ++ [{first, second}]
			#else
			#	output = output ++ [{second, first}]
			#end             
			#IO.puts(output)
			IO.puts("Number is Vampire")
			IO.puts(Integer.undigits(List.flatten(q)))
			IO.puts(Integer.undigits(p))
        	end
	end

	#function to check all possible pairs
	#TO DO: can use Enum.each instead
	def parse_list([head | tail],num) do
		check_flangs(List.flatten(head),num)
		parse_list(tail,num)
	end

	def parse_list([],_), do: nil

	#function to find permutation of given number
        def get_permutation([]), do: [[]]
        def get_permutation(list) do
                for elem <- list, rest <- get_permutation(list--[elem]), do: [elem|rest]
        end

	#function to check if number is vampire
	def check(current_number) do
		cur_num_list = Integer.digits(current_number)
		
		if rem(length(cur_num_list),2) == 0 do
			possible_flangs_list = Enum.uniq(get_permutation(cur_num_list))
			parse_list(possible_flangs_list, current_number)
			#IO.puts(Enum.uniq(output_flangs))
		end
	end
end

IO.puts("start")
{current_number, _ } = Integer.parse(IO.gets("Enter Number : "))
#current_number = 1260
VampireNumber.check(current_number)
