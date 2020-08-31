local triplets_game = {}

if not pcall(function() socket = require("socket") end) then 
  socket = nil
end

local field = {{'    0 1 2 3 4 5 6 7 8 9'}, 
            {"  ----------------------"},
            {"0 |"},
            {"1 |"},
            {"2 |"},
            {"3 |"},
            {"4 |"},
            {"5 |"},
            {"6 |"},
            {"7 |"},
            {"8 |"},
            {"9 |"}}

local input = 'a'

local matrix = {}
local prev_frame_time = os.clock()

local LEFT_EDGE = 0
local RIGHT_EDGE = 9
local UP_EDGE = 0
local DOWN_EDGE = 9
local COLORS_COUNT = 6

local EXPLOSION_CELL = -30
local EMPTY_CELL = -33

local LINE_NEEDED = 3

local EXIT = "q"
local HELP = "advice"
local FPS_CHANGE = "set fps"

local FPS = 3

local function fall() --[[ starting from the bottomn checks if blocks must fall --]]
  --[[ returns true if any block has to fall --]]
  res = false
  for y = DOWN_EDGE, UP_EDGE + 1, -1 do
    for x = LEFT_EDGE, RIGHT_EDGE do
      if (matrix[y][x] == EMPTY_CELL)and(matrix[y-1][x] < COLORS_COUNT)and(matrix[y-1][x] >= 0) then
        matrix[y][x], matrix[y-1][x] = matrix[y-1][x], matrix[y][x]
        res = true
      end
    end
  end
  
  for x = LEFT_EDGE, RIGHT_EDGE do --[[ need to know if any block on top is empty --]]
    if matrix[UP_EDGE][x] == EMPTY_CELL then
      res = true
    end
  end
  return res
end


local function fill_top() --[[ fills empty top blocks --]]
  for x = LEFT_EDGE, RIGHT_EDGE do
    if matrix[0][x] == EMPTY_CELL then
      matrix[0][x] = math.random(0,COLORS_COUNT-1)
    end
  end
end


local function check_cell_triplets(cell, dy, dx) --[[ recursively finds continuous chain of blocks with line length >= LINE_NEEDED, starting from cell --]]
  --[[ returns all blocks in chain, if line length < LINENEEDED returns nil--]]
  local res = {cell}
  if (matrix[cell[1]][cell[2]] >= 0) and (matrix[cell[1]][cell[2]] < COLORS_COUNT) then
    color = matrix[cell[1]][cell[2]]
  else
    return nil
  end
    
  matrix[cell[1]][cell[2]] = COLORS_COUNT --[[ prevent unlimited recursion --]]
    
  for dir = -1, 1, 2 do
    cur = {cell[1] + dir*dy, cell[2] + dir*dx}
    while (cur[1] <= DOWN_EDGE)and(cur[1] >= UP_EDGE)and(cur[2] <= RIGHT_EDGE)and(cur[2] >= LEFT_EDGE)and(matrix[cur[1]][cur[2]] == color) do
      table.insert(res, {cur[1], cur[2]})
      cur[1] = cur[1] + dir*dy;
      cur[2] = cur[2] + dir*dx;
    end
  end
  
  if #res >= LINE_NEEDED then
    for i = 2, #res do
      local another_res = check_cell_triplets(res[i], 1 - dy, 1 - dx) --[[ recursive call with oposite axis search--]]
      if another_res ~= nil then     
        for j = 2, #another_res do
          table.insert(res, another_res[j])
        end
      end
    end
    matrix[cell[1]][cell[2]] = color --[[ reverse change --]]
    return res
  else
    matrix[cell[1]][cell[2]] = color --[[ reverse change --]]
    return nil
  end
end


local function check_triples() --[[ calls check_cell_triplets for each cell --]]
  --[[ returns all triples on the map --]]
  res = {}
  for y = UP_EDGE, DOWN_EDGE do
    for x = LEFT_EDGE, RIGHT_EDGE do
      cell = {y, x}
      vertical_res = check_cell_triplets(cell, 1, 0)
      if vertical_res ~= nil then 
        for key, cell in pairs(vertical_res) do
          table.insert(res, cell)
        end
      end
            
      horizontal_res = check_cell_triplets(cell, 0, 1)
      if horizontal_res ~= nil then
        for key, cell in pairs(horizontal_res) do
          table.insert(res, cell)
        end
      end
      
    end
  end
  return res
end
local function remove_triples(cells) --[[ marks all given cells as EXPLOSION_CELL --]]
  for _,cell in pairs(cells) do
    matrix[cell[1]][cell[2]] = EXPLOSION_CELL
  end
end

local function remove_explosions() --[[ removes all EXPLOSION_CELL's from field --]]
  res = false
  for y = UP_EDGE, DOWN_EDGE do
    for x = LEFT_EDGE, RIGHT_EDGE do
      if matrix[y][x] == EXPLOSION_CELL then
        matrix[y][x] = EMPTY_CELL
        res = true
      end
    end
  end
  return res
end
local function is_stalled() --[[ checks if it is impossible to make a triple --]]
--[[ also returns first found cell to move to get triple(used for advice)--]]
  directions = {{0,1},{0,-1},{1,0},{-1,0}}
  for _,dir in pairs(directions) do
    for y = UP_EDGE, DOWN_EDGE do
      if (y + dir[1] >= UP_EDGE) and (y + dir[1] <= DOWN_EDGE) then
        for x = LEFT_EDGE, RIGHT_EDGE do
          if (x + dir[2] >= LEFT_EDGE) and (x + dir[2] <= RIGHT_EDGE) then
            cell = {y + dir[1], x + dir[2]}
            matrix[cell[1]][cell[2]], matrix[y][x] =  matrix[y][x], matrix[cell[1]][cell[2]]
            horizontal_res = check_cell_triplets(cell, 0, 1)
            vertical_res = check_cell_triplets(cell, 1, 0)
            matrix[cell[1]][cell[2]], matrix[y][x] =  matrix[y][x], matrix[cell[1]][cell[2]]
            if (horizontal_res ~= nil)or(vertical_res ~= nil) then
              return false, y, x
            end
          end
        end
      end
    end
  end
  return true
end
local function handle_input(input) --[[ check input format --]]
  --[[ returns false if no field modification needed, returns from,to if move was made --]]
  if input == EXIT then 
    return EXIT
  elseif input == HELP then
    _,y,x = is_stalled()
    io.write(y .. " " .. x .. "\n")
    return false
  else
    new_fps = string.match(input, FPS_CHANGE..' (%d+)')
    if new_fps ~= nil then
      FPS = new_fps
      return false
    end
  end
  y, x, dir = string.match(input, 'm (%d+) (%d+) ([u,d,l,r])')
  if (x == nil) or (y == nil) then 
    io.write("incorrect fomat\n")
    return false
  end
  
  from = {tonumber(y), tonumber(x)}
  if dir == "u" then 
    to = {from[1] - 1, from[2]}
  elseif dir == "d" then 
    to = {from[1] + 1, from[2]}
  elseif dir == "l" then 
    to = {from[1], from[2] - 1}
  else
    to = {from[1], from[2] + 1}
  end
  return from, to
end
function init() --[[ fills field with random colors, with no ready triples, with possible triples --]]
  repeat
    for y = UP_EDGE, DOWN_EDGE do
      matrix[y] = {}
      for x = LEFT_EDGE, RIGHT_EDGE do
        matrix[y][x] = math.random(0,COLORS_COUNT-1)
      end
    end
    triples = check_triples()
  until (is_stalled() == false) and (#triples == 0)
end

function tick() --[[ returns true if any movement was made --]]
  if fall() then --[[ if some pieces fall --]]
    fill_top()
    return true
  end
  
  if remove_explosions() == true then
    return true
  end
  
  triples = check_triples()
  if #triples ~= 0 then --[[ if new triple found --]]
    remove_triples(triples)
    return true
  end
  
  return false

end

function move(from, to) --[[ makes a move --]]
  --[[ returns true if move was successful, false else --]]
  if (from[1] > DOWN_EDGE)or(from[1] < UP_EDGE)or(from[2] < LEFT_EDGE)or(from[2] > RIGHT_EDGE)
     or(to[1] > DOWN_EDGE)or(to[1] < UP_EDGE)or(to[2] < LEFT_EDGE)or(to[2] > RIGHT_EDGE) then
    io.write("Out of range\n")
    return false
  else
    matrix[from[1]][from[2]], matrix[to[1]][to[2]] = matrix[to[1]][to[2]], matrix[from[1]][from[2]]
    horizontal_res = check_cell_triplets(from, 0, 1)
    if horizontal_res ~= nil then
      return true
    end
    vertical_res = check_cell_triplets(from, 1, 0)
    if vertical_res ~= nil then
      return true
    end
    horizontal_res = check_cell_triplets(to, 0, 1)
    if horizontal_res ~= nil then
      return true
    end
    vertical_res = check_cell_triplets(to, 1, 0)
    if vertical_res ~= nil then
      return true
    end
    matrix[from[1]][from[2]], matrix[to[1]][to[2]] = matrix[to[1]][to[2]], matrix[from[1]][from[2]] --[[ no triples found, undo turn --]]
    io.write("No triples \n")
    return false
  end
end

function mix() --[[ shuffles field until there are no triples, there are possible triples --]]
  io.write("No possible triplets, mixing the field\n")
  repeat
    for i = 1,(RIGHT_EDGE - LEFT_EDGE)*(DOWN_EDGE - UP_EDGE) do
      x1 = math.random(LEFT_EDGE,RIGHT_EDGE)
      x2 = math.random(LEFT_EDGE,RIGHT_EDGE)
      y1 = math.random(UP_EDGE,DOWN_EDGE)
      y2 = math.random(UP_EDGE,DOWN_EDGE)
      matrix[x1][y1], matrix[x2][y2] = matrix[x2][y2], matrix[x1][y1]
    end
    triples = check_triples()
  until (#triples == 0) and (is_stalled() == false)
end

function dump() --[[ draws field --]]
  if socket ~= nil then 
    socket.sleep(1/FPS - (os.clock() - prev_frame_time)) --[[ simple fps limiter --]]
  end
  
  for y = UP_EDGE, DOWN_EDGE do
      for x = LEFT_EDGE, RIGHT_EDGE do
        field[y+3][x+2] = string.char(string.byte("A") + matrix[y][x])
      end
  end

  for ks, str in pairs(field) do
    for kc, ch in pairs(str) do
      io.write(ch .. ' ')
    end
    io.write('\n')
  end
  io.write('\n')
  prev_frame_time = os.clock()
end

init()
dump()
while (input ~=EXIT) do
  repeat
    io.write("To make a move write m x(0-9) y(0-9) direction(r,l,u,d)\n")
    input = io.read()
    from, to = handle_input(input)
  until from ~= false
  
  if from ~= EXIT then
    if move(from,to) == true then 
      repeat 
        dump()
      until tick() == false
  
      if is_stalled() then
        mix()
      end --[[ if stalled --]]
    end --[[ if move--]]
  end --[[ if from--]]
  
end

return triplets_game