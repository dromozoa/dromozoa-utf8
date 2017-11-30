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

local encode3 = require "experimental.encode3"

if _VERSION == "Lua 5.3" then
return assert(load [====[
local char = string.char

local T = {}
for i = 0x0000, 0x007F do
  T[i] = char(i)
end
for i = 0x0080, 0x07FF do
  local b = i & 0x3F
  local a = i >> 6
  T[i] = char(a | 0xC0, b | 0x80)
end

return function (a)
  if a <= 0x07FF then
    return T[a]
  elseif a <= 0xFFFF then
    if 0xD800 <= a and a <= 0xDFFF then return nil end
    local c = a & 0x3F
    local a = a >> 6
    local b = a & 0x3F
    local a = a >> 6
    return char(a | 0xE0, b | 0x80, c | 0x80)
  elseif a <= 0x10FFFF then
    local d = a & 0x3F
    local a = a >> 6
    local c = a & 0x3F
    local a = a >> 6
    local b = a & 0x3F
    local a = a >> 6
    return char(a | 0xF0, b | 0x80, c | 0x80, d | 0x80)
  end
end
]====])()
else
  return encode3
end
