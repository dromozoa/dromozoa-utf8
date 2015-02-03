#! /usr/bin/env lua

local pure = require "dromozoa.utf8.pure"

local function concat(list, sep)
  local result = {}
  for i = 1, #list do
    result[i] = tostring(list[i])
  end
  return table.concat(result, sep)
end

local function compare(name, ...)
  io.write(name, "(", concat({...}, ","), ")\n")
  local result1 = { pcall(utf8[name], ...) }
  local result2 = { pcall(pure[name], ...) }
  io.write("  [1]={", concat(result1, ","), "}\n")
  io.write("  [2]={", concat(result2, ","), "}\n")
  if result1[1] then
    assert(result2[1])
    assert(#result1 == #result2)
    for i = 2, #result1 do
      assert(result1[i] == result2[i])
    end
  else
    assert(not result2[1])
  end
end

for i = -1, 2 do
  compare("offset", "", i)
  for j = -1, 2 do
    compare("offset", "", i, j)
  end
end

for i = -4, 5 do
  compare("offset", "foo", i)
  for j = -4, 5 do
    compare("offset", "foo", i, j)
  end
end


for i = -3, 4 do
  compare("offset", "ほえ", i)
  for j = -7, 8 do
    compare("offset", "ほえ", i, j)
  end
end

