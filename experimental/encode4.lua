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
return function (a)
  if a < 0 then
    return nil
  elseif a <= 0x7F then
    return char(a)
  elseif a <= 0x07FF then
    local b = a & 0x3F
    local a = a >> 6
    return char(a | 0xC0, b | 0x80)
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
  else
    return nil
  end
end
]====]
end

return assert((loadstring or load)(code))()
