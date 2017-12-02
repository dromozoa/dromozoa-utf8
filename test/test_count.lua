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

local function call(f1, f2, ...)
  print(...)
  print("=>", pcall(f1, ...))
  print("=>", pcall(f2, ...))
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
-- check(f1, f2, "あいう")

