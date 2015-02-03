#! /usr/bin/env lua

local pure = require "dromozoa.utf8.pure"

local function concat(list, sep)
  local result = {}
  for i = 1, #list do
    result[i] = tostring(list[i])
  end
  return table.concat(result, sep)
end

local pattern = {
  "(bad argument #%d+)";
  "(initial position is a continuation byte)";
}

local function test(name, ...)
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
    local p
    for i = 1, #pattern do
      p = result1[2]:match(pattern[i])
      if p ~= nil then
        assert(result2[2]:find(p, 1, false))
        break
      end
    end
    assert(p ~= nil)
  end
end

test("offset", "")
for i = -1, 2 do
  test("offset", "", i)
  for j = -1, 2 do
    test("offset", "", i, j)
  end
end

test("offset", "foo")
for i = -4, 5 do
  test("offset", "foo", i)
  for j = -4, 5 do
    test("offset", "foo", i, j)
  end
end

test("offset", "ほえ")
for i = -3, 4 do
  test("offset", "ほえ", i)
  for j = -7, 8 do
    test("offset", "ほえ", i, j)
  end
end

