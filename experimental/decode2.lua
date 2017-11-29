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

local range_empty = {}
local range_80_8F = {}
local range_80_9F = {}
local range_80_BF = {}
local range_90_BF = {}
local range_A0_BF = {}

for i = 0x00, 0xFF do
  range_empty[i] = false
  range_80_8F[i] = 0x80 <= i and i <= 0x8F and i % 0x40
  range_80_9F[i] = 0x80 <= i and i <= 0x9F and i % 0x40
  range_80_BF[i] = 0x80 <= i and i <= 0xBF and i % 0x40
  range_90_BF[i] = 0x90 <= i and i <= 0xBF and i % 0x40
  range_A0_BF[i] = 0xA0 <= i and i <= 0xBF and i % 0x40
end

local check_utf8_3 = {}
local check_utf8_4 = {}

for i = 0x00, 0xFF do
  if 0xE0 <= i and i <= 0xEF then
    if i == 0xE0 then
      check_utf8_3[i] = range_A0_BF
    elseif i == 0xED then
      check_utf8_3[i] = range_80_9F
    else
      check_utf8_3[i] = range_80_BF
    end
  else
    check_utf8_3[i] = range_empty
  end
end

for i = 0x00, 0xFF do
  if 0xF0 <= i and i <= 0xF4 then
    if i == 0xF0 then
      check_utf8_4[i] = range_90_BF
    elseif i == 0xF4 then
      check_utf8_4[i] = range_80_8F
    else
      check_utf8_4[i] = range_80_BF
    end
  else
    check_utf8_4[i] = range_empty
  end
end

local map1 = {}

for i = 0x00, 0xFF do
  if i <= 0x7F then
    map1[i] = i
  elseif i <= 0xC1 then
    map1[i] = false
  elseif i <= 0xDF then
    map1[i] = i % 0x20 * 0x40
  elseif i <= 0xEF then
    map1[i] = i % 0x10 * 0x1000
  elseif i <= 0xF4 then
    map1[i] = i % 0x08 * 0x400000
  else
    map1[i] = false
  end
end

return function (s, i)
  local j = i + 3
  local a, b, c, d = s:byte(i, j)
  local a2 = map1[a]
  if a2 then
    if a <= 0xDF then
      if a <= 0x7F then
        return i + 1, a2
      else
        local b = range_80_BF[b]
        if b then
          return i + 2, a2 + b
        end
      end
    else
      if a <= 0xEF then
        local b = check_utf8_3[a][b]
        local c = range_80_BF[c]
        if b and c then
          local b = b * 0x40
          return j, a2 + b + c
        end
      else
        local b = check_utf8_4[a][b]
        local c = range_80_BF[c]
        local d = range_80_BF[d]
        if b and c and d then
          local b = b * 0x1000
          local c = c * 0x40
          return i + 4, a2 + b + c + d
        end
      end
    end
  end
end
