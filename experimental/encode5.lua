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

local code = [====[
local char = string.char
return function (a)
  if a < 0 then
    return nil
  elseif a <= 0x7F then
    return char(a)
  elseif a <= 0x07FF then
    local b = a % 0x40
    local a = (a - b) / 0x40
    return char(a + 0xC0, b + 0x80)
  elseif a <= 0xFFFF then
    if 0xD800 <= a and a <= 0xDFFF then return nil end
    local c = a % 0x40
    local a = (a - c) / 0x40
    local b = a % 0x40
    local a = (a - b) / 0x40
    return char(a + 0xE0, b + 0x80, c + 0x80)
  elseif a <= 0x10FFFF then
    local d = a % 0x40
    local a = (a - d) / 0x40
    local c = a % 0x40
    local a = (a - c) / 0x40
    local b = a % 0x40
    local a = (a - b) / 0x40
    return char(a + 0xF0, b + 0x80, c + 0x80, d + 0x80)
  else
    return nil
  end
end
]====]

if _VERSION == "Lua 5.3" then
code = [====[
local char = string.char

local H1 = {}
local H2 = {}
local H3 = {}
local H4 = {}
local T = {}

for i = 0x00, 0x7F do
  H1[i] = char(i)
end
for i = 0x00, 0x3F do
  H2[i] = char(i | 0xC0)
  H3[i] = char(i | 0xE0)
  H4[i] = char(i | 0xF0)
  T[i] = char(i | 0x80)
end

return function (a)
  if a < 0 then
    return nil
  elseif a <= 0x7F then
    return H1[a]
  elseif a <= 0x07FF then
    local b = a & 0x3F
    local a = a >> 6
    return H2[a] .. T[b]
  elseif a <= 0xFFFF then
    if 0xD800 <= a and a <= 0xDFFF then return nil end
    local c = a & 0x3F
    local a = a >> 6
    local b = a & 0x3F
    local a = a >> 6
    return H3[a] .. T[b] .. T[c]
  elseif a <= 0x10FFFF then
    local d = a & 0x3F
    local a = a >> 6
    local c = a & 0x3F
    local a = a >> 6
    local b = a & 0x3F
    local a = a >> 6
    return H4[a] .. T[b] .. T[c] .. T[d]
  else
    return nil
  end
end
]====]
end

return assert((loadstring or load)(code))()
