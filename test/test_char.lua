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
  print(...)
  print("=>", unpack(result1))
  print("=>", unpack(result2))
end

local f1 = utf8.char
local f2 = pure.char

call(f1, f2, 0x41, 0x42, 0x43)
call(f1, f2, -1)
call(f1, f2, 0x10FFFF)
call(f1, f2, 0x110000)
call(f1, f2, 0xD800)
call(f1, f2, 0xDFFF)
call(f1, f2, "65")
call(f1, f2, "0x41")
call(f1, f2, true)
call(f1, f2, 65.5)
call(f1, f2, 0x41, nil, 0x43)
