
defmodule Project2 do
  use GenServer
  @moduledoc """
  Documentation for Project2.
  """

  @doc """
  Hello world.
  ## Examples
      iex> Project2.hello
      :world
  """



  def main(args) do
    if (Enum.count(args)!=3) do
      IO.puts" Illegal Arguments Provided"
      System.halt(1)
    else
        numNodes=Enum.at(args, 0)|>String.to_integer()

        topology=Enum.at(args, 1)
        algorithm=Enum.at(args, 2)

        numNodes = if topology == "rand2D" || topology == "honeycomb" || topology == "randhoneycomb" do
           getNextPerfectSq(numNodes)
         else
           numNodes
        end

        numNodes = if topology == "3Dtorus" do
          getNextPerfectCube(numNodes)
        else
          numNodes
        end

        allNodes = Enum.map((1..numNodes), fn(x) ->
          pid=start_node()
          updatePIDState(pid, x)
          pid
        end)

        table = :ets.new(:table, [:named_table,:public])
        :ets.insert(table, {"count",0})

        buildTopology(topology,allNodes)
        startTime = System.monotonic_time(:millisecond)

        startAlgorithm(algorithm, allNodes, startTime)
        infiniteLoop()
    end
  end

  def infiniteLoop() do
    infiniteLoop()
  end

  def buildTopology(topology,allNodes) do
    case topology do
      "full" ->buildFull(allNodes)
      "rand2D" ->buildRand2D(allNodes)
      "line" ->buildLine(allNodes)
      "3Dtorus" -> build3DTorus(allNodes)
      "honeycomb" ->buildHoneyComb(allNodes)
      "randhoneycomb" ->buildHoneyCombRandom(allNodes)
    end
  end

  def buildFull(allNodes) do
    Enum.each(allNodes, fn(k) ->
      adjList=List.delete(allNodes,k)
      updateAdjacentListState(k,adjList)
    end)
  end


  def getNextPerfectSq(numNodes) do
    round :math.pow(:math.ceil(:math.sqrt(numNodes)) ,2)
  end

  def buildRand2D(allNodes) do
    cDistance = 0.1
    #IO.puts("Building 2D Topology")
    numNodes=Enum.count allNodes
    side= Kernel.trunc(:math.sqrt numNodes)
    distanceFactor = 1/side
    coord = Enum.map(allNodes, fn(k) ->
      count=Enum.find_index(allNodes, fn(x) -> x==k end)
      x = rem(count, side)
      y = div(count, side)
      [k,x,y]
    end)
    #IO.inspect coord
    Enum.each(allNodes, fn(k) ->
      count=Enum.find_index(allNodes, fn(x) -> x==k end)
      x = rem(count, side)
      y = div(count, side)

      adjList = Enum.map(coord, fn(node) ->
        [pid, x1, y1] = node
        distance = :math.pow((x-x1)*distanceFactor, 2) + :math.pow((y-y1)*distanceFactor, 2)
        #IO.inspect list, label: distance
        if distance < cDistance do
          pid
        end
      end)
      adjList = Enum.filter(adjList, & !is_nil(&1))
      #IO.inspect(adjList)
      updateAdjacentListState(k,adjList)
    end)
  end

  def getNextPerfectCube(numNodes) do
    #round :math.pow(:math.ceil(:math.sqrt(numNodes)) ,2)
    1000
  end

  def build3DTorus(allNodes) do
    numNodes=Enum.count allNodes
    side = 10
    Enum.each(allNodes, fn(k) ->

      count=Enum.find_index(allNodes, fn(x) -> x==k end)

      index = if(!isNodeFrontPlane(count+1, side)) do
        count - 1
      else
        count + side - 1
      end
      neighbhourFront=Enum.fetch!(allNodes, index)

      index = if(!isNodeBackPlane(count+1, side)) do
        count + 1
      else
        count - side + 1
      end
      neighbhourBack=Enum.fetch!(allNodes, index)

      index = if(!isNodeLeftPlane(count+1, side)) do
        count - side
      else
        count + Kernel.trunc(:math.pow(side,2)) - side
      end
      neighbhourLeft=Enum.fetch!(allNodes, index)

      index = if(!isNodeRightPlane(count+1, side)) do
        count + side
      else
        count - Kernel.trunc(:math.pow(side,2)) + side
      end
      neighbhourRight=Enum.fetch!(allNodes, index)

      index = if(!isNodeBottomPlane(count+1, side)) do
        count + Kernel.trunc(:math.pow(side,2))
      else
        count - Kernel.trunc(:math.pow(side,3)) + Kernel.trunc(:math.pow(side,2))
      end
      neighbhourBottom=Enum.fetch!(allNodes, index)

      index = if(!isNodeTopPlane(count+1, side)) do
        count - Kernel.trunc(:math.pow(side,2))
      else
        count + Kernel.trunc(:math.pow(side,3)) - Kernel.trunc(:math.pow(side,2))
      end
      neighbhourTop=Enum.fetch!(allNodes, index)

      adjList=[neighbhourTop, neighbhourBottom, neighbhourLeft, neighbhourRight, neighbhourFront, neighbhourBack]
      #adjList = []
      #adjList = adjList ++ neighbhourTop
      IO.inspect adjList
      updateAdjacentListState(k,adjList)
    end)
  end

#####
#functions to get 3D
#####

  def isNodeTopPlane(index, side) do
    if index < :math.pow(side, 2) do
      true
    else
      false
    end
  end

  def isNodeBottomPlane(index, side) do
    size = :math.pow(side, 3) - :math.pow(side, 2)
    if index > size do
      true
    else
      false
    end
  end

  def isNodeFrontPlane(index, side) do
    if rem(index,side) == 1 do
      true
    else
      false
    end
  end

  def isNodeBackPlane(index, side) do
    if rem(index,side) == 0 do
      true
    else
      false
    end
  end

  def isNodeLeftPlane(index, side) do
    temp = rem(index, Kernel.trunc(:math.pow(side,2)))
    if temp <= side && temp > 0 do
      true
    else
      false
    end
  end

  def isNodeRightPlane(index, side) do
    temp = rem(index, Kernel.trunc(:math.pow(side,2)))
    if temp > (side - 1) * side || temp == 0 do
      true
    else
      false
    end
  end

#####
#End of 3D
#####
  def buildLine(allNodes) do

    numNodes=Enum.count allNodes
    Enum.each(allNodes, fn(k) ->
      count=Enum.find_index(allNodes, fn(x) -> x==k end)

      cond do
        numNodes==count+1 ->
          neighbhour1=Enum.fetch!(allNodes, count - 1)
          neighbhour2=List.first (allNodes)
          adjList=[neighbhour1,neighbhour2]
          updateAdjacentListState(k,adjList)
        true ->
          neighbhour1=Enum.fetch!(allNodes, count + 1)
          neighbhour2=Enum.fetch!(allNodes, count - 1)
          adjList=[neighbhour1,neighbhour2]
          updateAdjacentListState(k,adjList)
      end

    end)
  end

  def buildHoneyComb(allNodes) do
    numNodes=Enum.count allNodes
    side= Kernel.trunc(:math.sqrt numNodes)
    Enum.each(allNodes, fn(k) ->
      count=Enum.find_index(allNodes, fn(x) -> x==k end)

      index = if(!isNodeBottom(count,numNodes)) do
        count + side
      else
        count - (side*side - side)
      end
      neighbhourBottom=Enum.fetch!(allNodes, index)

      index = if(!isNodeTop(count,numNodes)) do
        count - side
      else
        count + (side*side - side)
      end
      neighbhourTop=Enum.fetch!(allNodes, index)

      x = rem(count, side)
      y = div(count, side)

      index = if (isEven(x) && isEven(y)) || (!isEven(x) && !isEven(y)) do
        if (!isNodeLeft(count,numNodes)) do
          count - 1
        else
          count + side - 1
        end
      else
        if (!isNodeRight(count,numNodes)) do
          count + 1
        else
          count - side + 1
        end
      end

      neighbhourSide=Enum.fetch!(allNodes, index)
      adjList = [neighbhourBottom, neighbhourTop, neighbhourSide]

      updateAdjacentListState(k,adjList)

    end)
  end

  def buildHoneyCombRandom(allNodes) do
    numNodes=Enum.count allNodes
    side= Kernel.trunc(:math.sqrt numNodes)
    Enum.each(allNodes, fn(k) ->
      tempList=allNodes
      count=Enum.find_index(allNodes, fn(x) -> x==k end)

      index = if(!isNodeBottom(count,numNodes)) do
        count + side
      else
        count - (side*side - side)
      end
      neighbhourBottom=Enum.fetch!(allNodes, index)
      tempList=List.delete_at(tempList,index)

      index = if(!isNodeTop(count,numNodes)) do
        count - side
      else
        count + (side*side - side)
      end
      neighbhourTop=Enum.fetch!(allNodes, index)
      tempList=List.delete_at(tempList,index)

      x = rem(count, side)
      y = div(count, side)

      index = if (isEven(x) && isEven(y)) || (!isEven(x) && !isEven(y)) do
        if (!isNodeLeft(count,numNodes)) do
          count - 1
        else
          count + side - 1
        end
      else
        if (!isNodeRight(count,numNodes)) do
          count + 1
        else
          count - side + 1
        end
      end
      neighbhourSide = Enum.fetch!(allNodes, index)
      tempList = List.delete_at(tempList,index)

      neighbhourRandom = Enum.random(tempList)

      adjList = [neighbhourBottom, neighbhourTop, neighbhourSide, neighbhourRandom]
      updateAdjacentListState(k,adjList)

    end)
  end

  def isEven (num) do
    if rem(num,2)==0 do
      true
    else
      false
    end
  end

###
# functions to get 2D grid
###
  def isNodeBottom(i,length) do
    if(i>=(length-(:math.sqrt length))) do
      true
    else
      false
    end
  end

  def isNodeTop(i,length) do
    if(i< :math.sqrt length) do
      true
    else
      false
    end
  end

  def isNodeLeft(i,length) do
    if(rem(i,round(:math.sqrt(length))) == 0) do
      true
    else
      false
    end
  end

  def isNodeRight(i,length) do
    if(rem(i + 1,round(:math.sqrt(length))) == 0) do
      true
    else
      false
    end
  end

####
# End of 2D grid
####

  def startAlgorithm(algorithm,allNodes, startTime) do
    case algorithm do
      "gossip" -> startGossip(allNodes, startTime)
      "push-sum" ->startPushSum(allNodes, startTime)
    end
  end

  def startGossip(allNodes, startTime) do
    chosenFirstNode = Enum.random(allNodes)
    updateCountState(chosenFirstNode, startTime, length(allNodes))
    recurseGossip(chosenFirstNode, startTime, length(allNodes))

  end

  def recurseGossip(chosenRandomNode, startTime, total) do
    myCount = getCountState(chosenRandomNode)

    cond do
      myCount < 11 ->
        adjacentList = getAdjacentList(chosenRandomNode)
        chosenRandomAdjacent=Enum.random(adjacentList)
        Task.start(Project2,:receiveMessage,[chosenRandomAdjacent, startTime, total])
        recurseGossip(chosenRandomNode, startTime, total)
      true ->
        Process.exit(chosenRandomNode, :normal)
    end
      recurseGossip(chosenRandomNode, startTime, total)
  end

  def startPushSum(allNodes, startTime) do
    chosenFirstNode = Enum.random(allNodes)
    IO.inspect chosenFirstNode
    #{s,pscount,adjList,w} = state
    GenServer.cast(chosenFirstNode, {:ReceivePushSum,0,0,startTime, 0.8*length(allNodes)})
  end


  def sendPushSum(randomNode, myS, myW,startTime, total_nodes) do
    GenServer.cast(randomNode, {:ReceivePushSum,myS,myW,startTime, total_nodes})
  end

  def updatePIDState(pid,nodeID) do
    GenServer.call(pid, {:UpdatePIDState,nodeID})
  end

  def updateAdjacentListState(pid,map) do
    GenServer.call(pid, {:UpdateAdjacentState,map})
  end

  def updateCountState(pid, startTime, total) do

      GenServer.call(pid, {:UpdateCountState,startTime, total})

  end

  def getCountState(pid) do
    GenServer.call(pid,{:GetCountState})
  end

  def receiveMessage(pid, startTime, total) do
    updateCountState(pid, startTime, total)
    recurseGossip(pid, startTime, total)
  end

  def getAdjacentList(pid) do
    GenServer.call(pid,{:GetAdjacentList})
  end

  def handle_cast({:ReceivePushSum,incomingS,incomingW,startTime, total_nodes},state) do

    {s,pscount,adjList,w} = state
    #IO.inspect w, label: s
    #IO.inspect state, label: "state"
    myS = s + incomingS
    myW = w + incomingW

    difference = abs((myS/myW) - (s/w))
    #list = [myS,myW,s,w, incomingS, incomingW, difference]
    #IO.inspect list
    #IO.inspect adjList, label:  difference
    if(difference < :math.pow(10,-10) && pscount==2) do
      count = :ets.update_counter(:table, "count", {2,1})
      if count >= total_nodes do
        endTime = System.monotonic_time(:millisecond) - startTime
        IO.puts "Convergence achieved in = " <> Integer.to_string(endTime) <>" Milliseconds"
        System.halt(1)
      end

    end
    pscount = if(difference <= :math.pow(10,-10) && pscount<2) do
       pscount + 1
      else
        0
    end

    state = {myS/2,pscount,adjList,myW/2}
    #IO.inspect state, label: difference

    randomNode = Enum.random(adjList)
    sendPushSum(randomNode, myS/2, myW/2,startTime, total_nodes)
    {:noreply,state}

  end

  def handle_call({:UpdatePIDState,nodeID}, _from ,state) do
    {a,b,c,d} = state
    state={nodeID,b,c,d}
    {:reply,a, state}
  end

  def handle_call({:UpdateCountState,startTime, total}, _from,state) do
    {a,b,c,d}=state
    if(b==0) do
      count = :ets.update_counter(:table, "count", {2,1})
      if(count == total) do
        endTime = System.monotonic_time(:millisecond) - startTime
        IO.puts "Convergence achieved in = #{endTime} Milliseconds"
        System.halt(1)
      end
    end
    state={a,b+1,c,d}
    {:reply, b+1, state}
  end

  def handle_call({:UpdateAdjacentState,map}, _from, state) do
    {a,b,_,d}=state
    state={a,b,map,d}
    {:reply,a, state}
  end

  def handle_call({:GetCountState}, _from ,state) do
    {_,b,_,_}=state
    {:reply,b, state}
  end

  def handle_call({:GetAdjacentList}, _from ,state) do
    {_,_,c,_}=state
    {:reply,c, state}
  end

  def init(:ok) do
    {:ok, {0,0,[],1}} #{s,pscount,adjList,w} , {nodeId,count,adjList,w}
  end

  def start_node() do
    {:ok,pid}=GenServer.start_link(__MODULE__, :ok,[])
    pid
  end

end

Project2.main(System.argv())
