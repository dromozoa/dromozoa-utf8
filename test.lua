#! /usr/bin/env lua

local pure = require "dromozoa.utf8.pure"
local unpack = table.unpack or unpack

local data = {
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
  {
    codepoint = {};
    utf8_char = "";
  };
}
if utf8 then
  local codepoint = data[1].codepoint
  local utf8_char = data[1].utf8_char

  local function test_char(...)
    local result1 = utf8.char(...)
    local result2 = utf8.char(...)
    assert(result1 == result2)
  end

  local function test_char_error(...)
    assert(not pcall(utf8.char, ...))
    assert(not pcall(pure.char, ...))
  end

  local function test_codes(...)
    local result1 = {}
    local result2 = {}
    for p, c in utf8.codes(...) do
      result1[#result1 + 1] = { p = p; c = c };
    end
    for p, c in pure.codes(...) do
      result2[#result2 + 1] = { p = p; c = c };
    end
    assert(#result1 == #result2)
    for i = 1, #result1 do
      assert(result1[i].p == result2[i].p)
      assert(result1[i].c == result2[i].c)
    end
  end

  local function test_codepoint(...)
    local result1 = { utf8.codepoint(...) }
    local result2 = { pure.codepoint(...) }
    assert(#result1 == #result2)
    for i = 1, #result1 do
      assert(result1[i] == result2[i])
    end
  end

  local function test_codepoint_error(...)
    assert(not pcall(utf8.codepoint, ...))
    assert(not pcall(pure.codepoint, ...))
  end

  test_char()
  test_char(unpack(codepoint))

  test_char_error(-1)
  test_char_error(0x110000)

  test_codes(utf8_char)

  test_codepoint(utf8_char)
  test_codepoint(utf8_char, 1)
  test_codepoint(utf8_char, "1")
  for i = 1, #codepoint do
    test_codepoint(utf8_char, 1, i)
  end
  for i = 1, #codepoint do
    test_codepoint(utf8_char, 1, -i)
  end
  test_codepoint(utf8_char, -1)
  test_codepoint(utf8_char, "-1")
  for i = 1, #codepoint do
    test_codepoint(utf8_char, 1, i)
  end
  for i = 1, #codepoint do
    test_codepoint(utf8_char, 1, -i)
  end

  test_codepoint_error(utf8_char, 0)
  test_codepoint_error("")
  test_codepoint_error("", 1)
end

for i = 1, #data do
  local codepoint = data[i].codepoint
  local utf8_char = data[i].utf8_char
  assert(utf8_char == pure.char(unpack(codepoint)))
  local i = 1
  for p, c in pure.codes(utf8_char) do
    assert(codepoint[i] == c)
    i = i + 1
  end
  if #utf8_char > 0 then
    assert(utf8_char == pure.char(pure.codepoint(utf8_char, 1, #utf8_char)))
    assert(utf8_char == pure.char(pure.codepoint(utf8_char, 1, -1)))
    assert(pure.char(codepoint[1]) == pure.char(pure.codepoint(utf8_char, 1)))
    assert(pure.char(codepoint[1]) == pure.char(pure.codepoint(utf8_char, 1, 1)))
  end
end
