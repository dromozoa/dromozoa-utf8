-- Copyright (C) 2017 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local unpack = table.unpack or unpack

local function each(f, s)
  local result = {}
  for p, c in f(s) do
    result[#result + 1] = p
    result[#result + 1] = c
  end
  return table.concat(result, ",")
end

local function call(f1, f2, ...)
  local result1 = { pcall(f1, ...) }
  local result2 = { pcall(f2, ...) }
  assert(result1[1] == result2[1])
  assert(#result1 == #result2)
  if result1[1] then
    for i = 2, #result1 do
      assert(result1[i] == result2[i])
    end
  else
    local message1 = result1[2]
    local message2 = result2[2]
    local a, b = message1:match("bad argument #(%d+) .-%((.*)%)$")
    if a then
      local c, d = assert(message2:match("bad argument #(%d+) .-%((.*)%)$"))
      assert(a == c)
      assert(b == d)
    elseif message1:match("invalid UTF%-8 code") then
      assert(message2:match("invalid UTF%-8 code"))
    else
      print(...)
      print("=>", unpack(result1))
      print("=>", unpack(result2))
    end
  end
end

local f1 = utf8.codepoint
local f2 = pure.codepoint

call(f1, f2, nil)
call(f1, f2, 3.5)
call(f1, f2, true)
call(f1, f2, "")
call(f1, f2, "foo")
call(f1, f2, "\255")
