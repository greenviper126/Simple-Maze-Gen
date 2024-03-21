--settings

local cols = 50
local rows = 50
local cellSize = 15

local height = 10
local width = 2

local worldOffset = Vector3.new(0,0,0)

---------------------------------------------------------------------

local mazeParts = Instance.new("Folder", workspace)
mazeParts.Name = "MazeParts"

local complete = false

local function wall(x, z, r)
	local part = Instance.new("Part")
	part.Anchored = true
	part.Size = Vector3.new(cellSize, height, width)
	part.Position = Vector3.new(x*cellSize, height/2, z*cellSize) + worldOffset
	part.Rotation = Vector3.new(part.Rotation.X, r, part.Rotation.Y)
	part.CFrame = part.CFrame * CFrame.new(Vector3.new(0, 0, -cellSize/2))
	part.Parent = mazeParts
	
	return part
end

local function floor(x, z)
	local part = Instance.new("Part")
	part.Anchored = true
	part.Size = Vector3.new(cellSize, 1, cellSize)
	part.Position = Vector3.new(x*cellSize, 0, z*cellSize) + worldOffset
	part.Parent = mazeParts
	
	return part
end

local maze = {}
maze.cols = {}
maze.rows = {}
maze.floor = {}

maze.position = {Vector3.new(1,0,1)}--table of the positions you made to get to your current point
maze.visited = {}--keeps track of positions you went to in total

maze.solution = {}--the positions needed to represent the solution/how to solve the maze

local function CreateGrid()
	for z=1, cols do
		for x=1, rows do
			table.insert(maze.cols, wall(x, z, 90))
			table.insert(maze.rows, wall(x, z, 0))
			table.insert(maze.floor, floor(x, z))
			table.insert(maze.visited, false)
		end
	end
	for x=1, rows do
		table.insert(maze.rows, wall(x, cols+1, 0))
	end
	for z=1, cols do
		table.insert(maze.cols, wall(rows+1, z, 90))
	end
	
	maze.visited[1] = true
	maze.rows[1]:Destroy()
	maze.rows[rows*cols+rows]:Destroy()
end

--sets boundries for generator by returning possible directions
local function VisitableCells(x, z)
	local cord = (z*rows)-rows+x
	local directions = {}
	
	--North
	if cord+rows <= rows*cols and not maze.visited[cord+rows] then
		table.insert(directions, 1)
	end
	--East
	if cord%rows ~= 1 and not maze.visited[cord-1] then
		table.insert(directions, 2)
	end
	--South
	if cord-rows > 0 and not maze.visited[cord-rows] then
		table.insert(directions, 3)
	end
	--West
	if cord%rows ~= 0 and not maze.visited[cord+1] then
		table.insert(directions, 4)
	end
	
	return directions
end

local function SearchPath()
	if maze.position == nil or table.maxn(maze.position) == 0 then
		return
	end
	
	local x = maze.position[#maze.position].X
	local z = maze.position[#maze.position].Z
	local cord = (z*rows)-rows+x
	local directions = VisitableCells(x, z)
	
	--if there is possible cells to visit then it will choose a random one
	if #directions > 0 then
		local NextCellDir = directions[math.random(1, #directions)]
		if NextCellDir == 1 then
			maze.visited[cord+rows] = true
			maze.rows[cord+rows]:Destroy()
			table.insert(maze.position,Vector3.new(x, 0, z+1))
		elseif NextCellDir == 2 then
			maze.visited[cord-1] = true
			maze.cols[cord]:Destroy()
			table.insert(maze.position,Vector3.new(x-1, 0, z))
		elseif NextCellDir == 3 then
			maze.visited[cord-rows] = true
			maze.rows[cord]:Destroy()
			table.insert(maze.position,Vector3.new(x, 0, z-1))
		elseif NextCellDir == 4 then
			maze.visited[cord+1] = true
			maze.cols[cord+1]:Destroy()
			table.insert(maze.position,Vector3.new(x+1, 0, z))
		end
	else
		table.remove(maze.position)--backtrack to last position
	end
	
	SearchPath()
end

--MAIN---------------------------------------------------------------

CreateGrid()
SearchPath()

print("maze is completed")
