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

local function check_input(input)
  return true
end

local function is_stalled()
  return false
end

local function fall()
  return false
end

local function check_triples()
  return false
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
  
  if fall(matrix) --[[ if some pieces fall --]]
    then return true
  end
  
  if check_triples() --[[ if new triple found --]]
    then return true
  end
  
  return false
end

function move(from, to)
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
while (input ~="exit") do
  repeat
    io.write("Please, make a move in format m x(0-9) y(0-9) direction(r,l,u,d)\n")
    input = io.read()
  until check_input(input)
  
  repeat 
    dump()
  until tick() == false
  
  while is_stalled() do
    mix()
  end
end

return triplets_game