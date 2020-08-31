local triplets_game = {}

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

local left_edge = 0
local right_edge = 9
local up_edge = 0
local down_edge = 9
local colors_count = 6

local explosion = -29;
local empty = -32;

local exit = "exit"

local function handle_input(input)
  if input == exit then 
    return exit
  end
  y, x, dir = string.match(input, 'm (%d+) (%d+) ([u,d,l,r])')
  if (x == nil) or (y == nil) then 
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

local function is_stalled()
  return false
end

local function fall()
  return false
end

local function check_cell_triplets(cell, dy, dx)
  local res = {cell}
  if (matrix[cell[1]][cell[2]] >= 0) and (matrix[cell[1]][cell[2]] < colors_count) then
    color = matrix[cell[1]][cell[2]]
  else
    return nil
  end
  
  for dir = -1, 1, 2 do
    cur = {cell[1] + dir*dy, cell[2] + dir*dx}
    while (cur[1] <= down_edge)and(cur[1] >= up_edge)and(cur[2] <= right_edge)and(cur[2] >= left_edge)and(matrix[cur[1]][cur[2]] == color) do
      table.insert(res, {cur[1], cur[2]})
      cur[1] = cur[1] + dir*dy;
      cur[2] = cur[2] + dir*dx;
    end
  end
  
  if #res >= 3 then
    for i = 2, #res do
      local another_res = check_cell_triplets(res[i], 1 - dy, 1 - dx)
      if another_res ~= nil then     
        for j = 2, #another_res do
          table.insert(res, another_res[j])
        end
      end
    end
    return res
  else
    return nil
  end
end



local function check_triples()
  res = false
  for y = up_edge, down_edge do
    for x = left_edge, right_edge do
      cell = {y, x}
      vertical_res = check_cell_triplets(cell, 1, 0)
      if vertical_res ~= nil then 
        for key, cell in pairs(vertical_res) do
          if pcall(function()matrix[cell[1]][cell[2]] = explosion end) == false then
            heh = "kek"
          end
        end
        res = true
      end
      
      horizontal_res = check_cell_triplets(cell, 0, 1)
      if horizontal_res ~= nil then
        for key, cell in pairs(horizontal_res) do
          matrix[cell[1]][cell[2]] = explosion
        end
        res = true
      end
      
    end
  end
  return res
end

function init()
  repeat
    for y = up_edge, down_edge do
      matrix[y] = {}
      for x = left_edge, right_edge do
        matrix[y][x] = math.random(colors_count)
      end
    end
    kek = "w"
  until (is_stalled() == false) and (check_triples() == false)
end

function tick() --[[ returns true if any movement was made --]]
  
  if fall(matrix) then --[[ if some pieces fall --]]
    return true
  end
  
  if check_triples() then --[[ if new triple found --]]
    return true
  end
  
  return false
end

function move(from, to)
  if (from[1] > down_edge)or(from[1] < up_edge)or(from[2] < left_edge)or(from[2] > right_edge)
     or(to[1] > down_edge)or(to[1] < up_edge)or(to[2] < left_edge)or(to[2] > right_edge) then
     return false
  else
    matrix[from[1]][from[2]], matrix[to[1]][to[2]] = matrix[to[1]][to[2]], matrix[from[1]][from[2]]
    return true
  end
end

function mix()
end

function dump()
  for y = up_edge, down_edge do
      for x = left_edge, right_edge do
        field[y+3][x+2] = string.char(string.byte("A") + matrix[y][x] - 1)
      end
  end

  for ks, str in pairs(field) do
    for kc, ch in pairs(str) do
      io.write(ch .. ' ')
    end
    io.write('\n')
    --[[ print('\n'); --]]
  end
end

init()
dump()
while (input ~=exit) do
  repeat
    io.write("Please, make a move in format m x(0-9) y(0-9) direction(r,l,u,d)\n")
    input = io.read()
    from, to = handle_input(input)
  until y ~= false
  
  if from ~= exit then
    if move(from,to) == false then 
      io.write("Out of range\n")
    else
      repeat 
        dump()
      until tick() == false
  
      while is_stalled() do
        mix()
      end --[[ while --]]
    end --[[ if move--]]
  end --[[ if from--]]
  
end

return triplets_game