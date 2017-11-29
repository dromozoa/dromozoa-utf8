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

local function fill(t, v)
  for i = 0x00, 0xFF do
    t[i] = v
  end
  return t
end

local TA_80_BF = fill({}, false)
local TB_80_BF = fill({}, false)
local TB_80_9F = fill({}, false)
local TB_A0_BF = fill({}, false)
local TC_80_BF = fill({}, false)
local TC_80_8F = fill({}, false)
local TC_90_BF = fill({}, false)

for i = 0x80, 0xBF do
  local a = i % 0x40
  local b = a * 0x40
  local c = b * 0x40

  TA_80_BF[i] = a
  TB_80_BF[i] = b
  TB_80_9F[i] = i <= 0x9F and b
  TB_A0_BF[i] = 0xA0 <= i and b
  TC_80_BF[i] = c
  TC_80_8F[i] = i <= 0x8F and c
  TC_90_BF[i] = 0x90 <= i and c
end

local H1 = fill({}, false)
local H2 = fill({}, false)

for i = 0x00, 0xFF do
  if i <= 0x7F then
    H1[i] = i
  elseif i <= 0xC1 then
    -- noop
  elseif i <= 0xDF then
    H1[i] = i % 0x20 * 0x40
  elseif i <= 0xEF then
    H1[i] = i % 0x10 * 0x1000
    if i == 0xE0 then
      H2[i] = TB_A0_BF
    elseif i == 0xED then
      H2[i] = TB_80_9F
    else
      H2[i] = TB_80_BF
    end
  elseif i <= 0xF4 then
    H1[i] = i % 0x08 * 0x40000
    if i == 0xF0 then
      H2[i] = TC_90_BF
    elseif i == 0xF4 then
      H2[i] = TC_80_8F
    else
      H2[i] = TC_80_BF
    end
  else
    -- noop
  end
end

local byte = string.byte

return function (s, i)
  local j = i + 3
  local a, b, c, d = byte(s, i, j)
  local x = H1[a]
  if x then
    if a <= 0xDF then
      if a <= 0x7F then
        return i + 1, x
      else
        local b = TA_80_BF[b]
        if b then
          return i + 2, x + b
        end
      end
    else
      if a <= 0xEF then
        local b = H2[a][b]
        local c = TA_80_BF[c]
        if b and c then
          return j, x + b + c
        end
      else
        local b = H2[a][b]
        local c = TB_80_BF[c]
        local d = TA_80_BF[d]
        if b and c and d then
          return i + 4, x + b + c + d
        end
      end
    end
  end
end
