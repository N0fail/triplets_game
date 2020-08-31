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

local input = 'a';

local matrix;

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
  matrix = 10;
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
  for i = 0, 9 do
      for j = 0, 9 do
        field[i+3][j+2] = string.char(string.byte("A") + j)
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
io.write(matrix .. "\n")
while (input ~="exit") do
  repeat
    io.write("Please, make a move in format m x(0-9) y(0-9) direction(r,l,u,d)\n")
    input = io.read()
  until check_input(input)
  
  while tick() do
    dump()
  end
  
  while is_stalled() do
    mix()
  end
end

return triplets_game