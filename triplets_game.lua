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

local explosion_cell = -30;
local empty_cell = -33;

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

local function fall()
  res = false
  for y = down_edge, up_edge + 1, -1 do
    for x = left_edge, right_edge do
      if (matrix[y][x] == empty_cell)and(matrix[y-1][x] < colors_count)and(matrix[y-1][x] >= 0) then
        matrix[y][x], matrix[y-1][x] = matrix[y-1][x], matrix[y][x]
        res = true
      end
    end
  end
  return res
end

local function fill_top()
  for x = left_edge, right_edge do
    if matrix[0][x] == empty_cell then
      matrix[0][x] = math.random(0,colors_count-1)
    end
  end
end

local function check_cell_triplets(cell, dy, dx)
  local res = {cell}
  if (matrix[cell[1]][cell[2]] >= 0) and (matrix[cell[1]][cell[2]] < colors_count) then
    color = matrix[cell[1]][cell[2]]
  else
    return nil
  end
    
  matrix[cell[1]][cell[2]] = colors_count --[[ prevent unlimited recursion --]]
    
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
    matrix[cell[1]][cell[2]] = color --[[ reverse change --]]
    return nil
  end
end



local function check_triples()
  res = {}
  for y = up_edge, down_edge do
    for x = left_edge, right_edge do
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
local function remove_cells(cells)
  for _,cell in pairs(cells) do
    matrix[cell[1]][cell[2]] = empty_cell
  end
end
local function is_stalled()
  directions = {{0,1},{0,-1},{1,0},{-1,0}}
  for _,dir in pairs(directions) do
    for y = up_edge, down_edge do
      if (y + dir[1] >= up_edge) and (y + dir[1] <= down_edge) then
        for x = left_edge, right_edge do
          if (x + dir[2] >= left_edge) and (x + dir[2] <= right_edge) then
            cell = {y + dir[1], y + dir[2]}
            matrix[cell[1]][cell[2]], matrix[y][x] =  matrix[y][x], matrix[cell[1]][cell[2]]
            horizontal_res = check_cell_triplets(cell, 0, 1)
            vertical_res = check_cell_triplets(cell, 1, 0)
            matrix[cell[1]][cell[2]], matrix[y][x] =  matrix[y][x], matrix[cell[1]][cell[2]]
            if (horizontal_res ~= nil)or(vertical_res ~= nil) then
              return false
            end
          end
        end
      end
    end
  end
  return true
end

function init()
  repeat
    for y = up_edge, down_edge do
      matrix[y] = {}
      for x = left_edge, right_edge do
        matrix[y][x] = math.random(0,colors_count-1)
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
  
  triples = check_triples()
  if #triplets ~= 0 then --[[ if new triple found --]]
    remove_cells(triples)
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
  repeat
    for i = 1,(right_edge - left_edge)*(down_edge - up_edge) do
      x1 = math.random(left_edge,right_edge)
      x2 = math.random(left_edge,right_edge)
      y1 = math.random(up_edge,down_edge)
      y2 = math.random(up_edge,down_edge)
      matrix[x1][y1], matrix[x2][y2] = matrix[x2][y2], matrix[x1][y1]
    end
    triples = check_triples()
  until (#triples == 0) and (is_stalled() == false)
end

function dump()
  for y = up_edge, down_edge do
      for x = left_edge, right_edge do
        field[y+3][x+2] = string.char(string.byte("A") + matrix[y][x])
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
  
      if is_stalled() then
        mix()
      end --[[ if stalled --]]
    end --[[ if move--]]
  end --[[ if from--]]
  
end

return triplets_game