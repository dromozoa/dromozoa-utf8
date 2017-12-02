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
    else
      print(...)
      print("=>", unpack(result1))
      print("=>", unpack(result2))
    end
  end
end

local function check(f1, f2, s)
  local n = #s + 2

  for i = -n, n do
    for j = -n, n do
      call(f1, f2, s, i, j)
    end
  end
end

local f1 = utf8.len
local f2 = pure.len
call(f1, f2, nil, 1, 1)
call(f1, f2, 3.14, 1, 1)
call(f1, f2, "foo", 1, 1)
call(f1, f2, true, 1, 1)
call(f1, f2, {}, 1, 1)
call(f1, f2, call, 1, 1)
call(f1, f2, "foo", "1", "1")
call(f1, f2, "foo", 1.5, 1.5)
call(f1, f2, "foo", 1, "2.5")
call(f1, f2, "foo", false, false)

check(f1, f2, "あいう")

