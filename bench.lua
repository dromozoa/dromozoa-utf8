#! /usr/bin/env lua

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
local difftime = os.difftime
local time = os.time
local unpack = table.unpack or unpack

local utf8_char = table.concat {
  string.char(0x41, 0xE2, 0x89, 0xA2, 0xCE, 0x91, 0x2E);
  string.char(0xED, 0x95, 0x9C, 0xEA, 0xB5, 0xAD, 0xEC, 0x96, 0xB4);
  string.char(0xE6, 0x97, 0xA5, 0xE6, 0x9C, 0xAC, 0xE8, 0xAA, 0x9E);
  string.char(0xEF, 0xBB, 0xBF, 0xF0, 0xA3, 0x8E, 0xB4);
}

local codepoint = {
  0x0041, 0x2262, 0x0391, 0x002E,
  0xD55C, 0xAD6D, 0xC5B4,
  0x65E5, 0x672C, 0x8A9E,
  0xFEFF, 0x0233B4,
}

local result, unix = pcall(require, "dromozoa.unix")
if result then
  time = function ()
    return unix.clock_gettime(unix.CLOCK_MONOTONIC_RAW)
  end
  difftime = function (t2, t1)
    return (t2 - t1):tonumber()
  end
end

local n = tonumber(arg[1]) or 100000

local function bench(name, fn)
  local t1 = time()
  fn(utf8[name], n)
  local t2 = time()
  local t = difftime(t2, t1)

  local t1 = time()
  fn(pure[name], n)
  local t2 = time()
  local u = difftime(t2, t1)

  print(name, t, u, u / t)
end

print("name", "utf8", "pure")

bench("char", function (fn, n)
  local x = 0
  for i = 1, n do
    local result = fn(unpack(codepoint))
    x = x + #result
  end
end)

bench("codes", function (fn, n)
  local x = 0
  for i = 1, n do
    for p, c in fn(utf8_char) do
      x = x + 1
    end
  end
end)

bench("codepoint", function (fn, n)
  local x = 0
  for i = 1, n do
    x = x + fn(utf8_char)
  end
end)

bench("len", function (fn, n)
  local x = 0
  for i = 1, n do
    x = x + fn(utf8_char)
  end
end)

bench("offset", function (fn, n)
  local x = 0
  for i = 1, n do
    x = x + fn(utf8_char, -1)
  end
end)
