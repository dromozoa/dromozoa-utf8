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

local encode7 = require "experimental.encode7"

if _VERSION == "Lua 5.3" then
return assert(load [====[
local char = string.char

local T = {}
for i = 0x0000, 0x003F do
  T[i] = char(i + 0x80)
end

local T1 = {}
for i = 0x0000, 0x007F do
  T1[i] = char(i)
end
for i = 0x0080, 0x07FF do
  local b = i % 0x40
  local a = (i - b) / 0x40
  T1[i] = char(a + 0xC0, b + 0x80)
end

local T2 = {}
for i = 0x0000, 0x03FF do
  if i <= 0x001F or (0x0360 <= i and i <= 0x037F) then
    T2[i] = false
  else
    local b = i % 0x40
    local a = (i - b) / 0x40
    T2[i] = char(a + 0xE0, b + 0x80)
  end
end

local T3 = {}
for i = 0x0000, 0x010F do
  if i <= 0x000F then
    T3[i] = false
  else
    local b = i % 0x40
    local a = (i - b) / 0x40
    T3[i] = char(a + 0xF0, b + 0x80)
  end
end

return function (a)
  if a <= 0x07FF then
    return T1[a]
  elseif a <= 0xFFFF then
    local c = a & 0x3F
    local a = a >> 6
    local v = T2[a]
    if v then
      return v .. T[c]
    end
  elseif a <= 0x10FFFF then
    local d = a & 0x3F
    local a = a >> 6
    local c = a & 0x3F
    local a = a >> 6
    local v = T3[a]
    if v then
      return v .. T[c] .. T[d]
    end
  end
end
]====])()
else
  return encode7
end
