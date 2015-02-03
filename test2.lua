#! /usr/bin/env lua

local unpack = table.unpack or unpack
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
  "(invalid UTF%-8 code)";
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
        assert(result2[2]:find(p, 1, true))
        break
      end
    end
    assert(p ~= nil)
  end
end

local function test_codes(...)
  io.write("codes(", concat({...}, ","), ")\n")
  local result1 = {}
  for p, c in utf8.codes(...) do
    result1[#result1 + 1] = p
    result1[#result1 + 1] = c
  end
  io.write("  [1]={", concat(result1, ","), "}\n")
  local result2 = {}
  for p, c in pure.codes(...) do
    result2[#result2 + 1] = p
    result2[#result2 + 1] = c
  end
  io.write("  [2]={", concat(result1, ","), "}\n")
  assert(#result1 == #result2)
  for i = 1, #result1 do
    assert(result1[i] == result2[i])
  end
end

local data = {
  {
    codepoint = {};
    utf8_char = "";
  };
  {
    codepoint = { 0x66, 0x6F, 0x6F };
    utf8_char = "foo";
  };
  {
    codepoint = { 0x0041, 0x2262, 0x0391, 0x002E };
    utf8_char = string.char(0x41, 0xE2, 0x89, 0xA2, 0xCE, 0x91, 0x2E);
  };
  {
    codepoint = { 0xD55C, 0xAD6D, 0xC5B4 };
    utf8_char = string.char(0xED, 0x95, 0x9C, 0xEA, 0xB5, 0xAD, 0xEC, 0x96, 0xB4);
  };
  {
    codepoint = { 0x65E5, 0x672C, 0x8A9E };
    utf8_char = string.char(0xE6, 0x97, 0xA5, 0xE6, 0x9C, 0xAC, 0xE8, 0xAA, 0x9E);
  };
  {
    codepoint = { 0xFEFF, 0x0233B4 };
    utf8_char = string.char(0xEF, 0xBB, 0xBF, 0xF0, 0xA3, 0x8E, 0xB4);
  };
}

assert(utf8.charpattern == pure.charpattern)

for i = 1, #data do
  local codepoint = data[i].codepoint
  local utf8_char = data[i].utf8_char

  local m = #codepoint + 2
  local n = #utf8_char + 2

  test("char", unpack(codepoint))

  test_codes(utf8_char)

  test("codepoint", utf8_char)
  for j = -n, n do
    test("codepoint", utf8_char, j)
    for k = -n, n do
      test("codepoint", utf8_char, j, k)
    end
  end

  test("len", utf8_char)
  for j = -n, n do
    test("len", utf8_char, j)
    for k = -n, n do
      test("len", utf8_char, j, k)
    end
  end

  test("offset", utf8_char)
  for j = -m, m do
    test("offset", utf8_char, j)
    for k = -n, n do
      test("offset", utf8_char, j, k)
    end
  end
end
