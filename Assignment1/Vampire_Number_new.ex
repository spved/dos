defmodule Vampire_Number do


	#function to check flangs
        def check_flangs(list,num) do
                num_length = length(list)/2
                [p|q] = Enum.chunk_every(list, Kernel.trunc(num_length))
		first = Integer.undigits(p)
		second = Integer.undigits(List.flatten(q))
                l1 = []
                if num == first * second do
                        string = ""
                     	#if first < second do     
			#	output = output ++ [{first, second}]
			#else
			#	output = output ++ [{second, first}]
			#end             
			#IO.puts(output)
                        # [0 | list]
                        n1  = Integer.undigits(List.flatten(q))
                        n2 =  Integer.undigits(p)
			#IO.puts("Number is Vampire")
                        IO.puts(num)
			IO.puts(n1)
                        l1 = l1 ++ [n1]
                        #output1 = [output1 | n1]
			IO.puts(n2)
                         l1 = l1 ++ [n2]
                        #output1 = [output1 | n2]
                        
                        #IO.inspect l1
                        #IO.puts Enum.member?(l1, 60)
                        
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
        def check1(current_number) do
          spawn(Vampire_Number, :check, [])
          #send pid,{self(), "spawning"}
        end
        
      
end

IO.puts("start")
{current_number1, _ } = Integer.parse(IO.gets("Enter Number1 : "))
{current_number2, _ } = Integer.parse(IO.gets("Enter Number2 : "))
#current_number = 1260
Enum.each(current_number1..current_number2, &Vampire_Number.check/1)
#Enum.each(current_number1..current_number2, spawn(Vampire_Number, :check, ))
