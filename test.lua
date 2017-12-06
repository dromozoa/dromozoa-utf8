-- Copyright (C) 2015,2017 Tomoyuki Fujimori <moyu@dromozoa.com>
--
-- This file is part of dromozoa-utf8.
--
-- dromozoa-utf8 is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dromozoa-utf8 is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-utf8.  If not, see <http://www.gnu.org/licenses/>.

local pure = require "dromozoa.utf8.pure"
pure.offset = require "experimental.offset2"

local unpack = table.unpack or unpack

local pack = table.pack or function (...)
  return { n = select("#", ...), ... }
end

local reasons = {
  "initial position is a continuation byte";
  "invalid UTF-8 code";
}

local count = 0
local expect
if _VERSION ~= "Lua 5.3" then
  expect = assert(loadfile("test.exp"))()
end

local function each(module, ...)
  local result = {}
  for p, c in module.codes(...) do
    result[#result + 1] = p
    result[#result + 1] = c
  end
  return unpack(result)
end

local function run(module, name, ...)
  if name == "charpattern" then
    return pack(true, module.charpattern)
  elseif name == "codes" then
    return pack(pcall(each, module, ...))
  else
    return pack(pcall(module[name], ...))
  end
end

local function dump(v)
  local t = type(v)
  if t == "nil" then
    return "nil"
  elseif t == "number" then
    return ("%.17g"):format(v)
  elseif t == "string" then
    return ("%q"):format(v)
  elseif t == "boolean" then
    if v then
      return "true"
    else
      return "false"
    end
  elseif t == "table" then
    local n = assert(v.n)
    local result = {}
    for i = 1, #v do
      result[i] = dump(v[i])
    end
    return "{n=" .. n .. "," .. table.concat(result, ",") .. "}"
  end
end

local function check(name, ...)
  io.stderr:write(name, " ", dump(pack(...)), "\n")
  local result1
  if expect then
    count = count + 1
    result1 = expect[count]
  else
    result1 = run(utf8, name, ...)
  end
  local result2 = run(pure, name, ...)

  io.stderr:write("  utf8 ", dump(result1), "\n")
  io.stderr:write("  pure ", dump(result2), "\n")

  if result1[1] then
    assert(result2[1])
    local n = result1.n
    if n < result2.n then
      n = result2.n
    end
    for i = 2, n do
      assert(result1[i] == result2[i])
    end
  else
    assert(not result2[1])
    local message1 = result1[2]
    local message2 = result2[2]
    local bad_argument, reason = message1:match("(bad argument #%d+) .-%((.*)%)$")
    if bad_argument then
      reason = reason:gsub("expected, got no value$", "expected, got nil")
      if not message2:find(bad_argument, nil, true) or not message2:find(reason, nil, true) then
        assert(message2:find("attempt to perform arithmetic on", nil, true))
      end
    else
      local checked
      for i = 1, #reasons do
        local reason = reasons[i]
        if message1:find(reason, nil, true) then
          assert(message2:find(reason, nil, true))
          checked = true
          break
        end
      end
      assert(checked)
    end
  end
  io.write("  ", dump(result1), ";\n")
end

io.write("return {\n")

check("charpattern")

check("char", -1)
check("char", 0, -1)
check("char", 0x10FFFF)
check("char", 0x110000)
check("char", 0, 0x10FFFF)
check("char", 0, 0x110000)
check("char", 0x41, 0x42, 0x43)
check("char", "65", "0x42")
check("char", 65.5)
check("char", true)
check("char", 0x41, nil, 0x43)

check("codes", string.char(0xE2))
check("codes", string.char(0xE2, 0x89))
check("codes", string.char(0xE2, 0x89, 0xA2))
check("codes", string.char(0xE2))
check("codes", string.char(0xE2, 0x00))
check("codes", string.char(0xE2, 0x89, 0x00))
check("codes", string.char(0xE2, 0xFF))
check("codes", string.char(0xE2, 0x89, 0xFF))

local data = {
  65;
  65.5;
  0;
  1;
  1.5;
  -1;
  -2;
  -4;
  "";
  "foo";
  "1";
  "0x01";
  true;
  false;
  { n = 0 };
}

for i = 0, #data do
  local a = data[i]
  for j = 0, #data do
    local b = data[j]
    for k = 0, #data do
      local c = data[k]
      check("char", a, b, c)
      check("codes", a, b, c)
      check("codepoint", a, b, c)
      check("len", a, b, c)
      check("offset", a, b, c)
    end
  end
end

local data = {
  {
    codepoint = {};
    utf8_char = "";
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
    codepoint = { 0xFEFF, 0x233B4 };
    utf8_char = string.char(0xEF, 0xBB, 0xBF, 0xF0, 0xA3, 0x8E, 0xB4);
  };
  {
    codepoint = {
      0x0041, 0x2262, 0x0391, 0x002E,
      0xD55C, 0xAD6D, 0xC5B4,
      0x65E5, 0x672C, 0x8A9E,
      0xFEFF, 0x0233B4,
    };
    utf8_char = string.char(
        0x41,
        0xE2, 0x89, 0xA2,
        0xCE, 0x91,
        0x2E,
        0xED, 0x95, 0x9C,
        0xEA, 0xB5, 0xAD,
        0xEC, 0x96, 0xB4,
        0xE6, 0x97, 0xA5,
        0xE6, 0x9C, 0xAC,
        0xE8, 0xAA, 0x9E,
        0xEF, 0xBB, 0xBF,
        0xF0, 0xA3, 0x8E, 0xB4);
  };
}

for i = 1, #data do
  local codepoint = data[i].codepoint
  local utf8_char = data[i].utf8_char

  local m = #codepoint + 2
  local n = #utf8_char + 2

  check("char", unpack(codepoint))
  check("codes", utf8_char)

  check("codepoint", utf8_char)
  for j = -n, n do
    check("codepoint", utf8_char, j)
    for k = -n, n do
      check("codepoint", utf8_char, j, k)
    end
  end

  check("len", utf8_char)
  for j = -n, n do
    check("len", utf8_char, j)
    for k = -n, n do
      check("len", utf8_char, j, k)
    end
  end

  check("offset", utf8_char)
  for j = -m, m do
    check("offset", utf8_char, j)
    for k = -n, n do
      check("offset", utf8_char, j, k)
    end
  end
end

io.write("}\n")
