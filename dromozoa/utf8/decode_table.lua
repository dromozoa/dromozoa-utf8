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
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-utf8. If not, see <https://www.gnu.org/licenses/>.

local TA_80_BF = {}
local TB_80_BF = {}
local TB_A0_BF = {}
local TB_80_9F = {}
local TC_80_BF = {}
local TC_80_8F = {}
local TC_90_BF = {}

for i = 0x00, 0x7F do
  TA_80_BF[i] = false
  TB_80_BF[i] = false
  TB_80_9F[i] = false
  TB_A0_BF[i] = false
  TC_80_BF[i] = false
  TC_80_8F[i] = false
  TC_90_BF[i] = false
end

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

local A = {}
local B = {}

for i = 0x00, 0xF4 do
  if i <= 0x7F then
    A[i] = i
    B[i] = false
  elseif i <= 0xC1 then
    A[i] = false
    B[i] = false
  elseif i <= 0xDF then
    A[i] = i % 0x20 * 0x40
    B[i] = TA_80_BF
  elseif i <= 0xEF then
    A[i] = i % 0x10 * 0x1000
    if i == 0xE0 then
      B[i] = TB_A0_BF
    elseif i == 0xED then
      B[i] = TB_80_9F
    else
      B[i] = TB_80_BF
    end
  else
    A[i] = i % 0x08 * 0x40000
    if i == 0xF0 then
      B[i] = TC_90_BF
    elseif i == 0xF4 then
      B[i] = TC_80_8F
    else
      B[i] = TC_80_BF
    end
  end
end

return {
  A = A;
  B = B;
  TA = TA_80_BF;
  TB = TB_80_BF;
  TC = TC_80_BF;
}
