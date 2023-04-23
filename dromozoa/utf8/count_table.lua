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

local A = {}
local B_80_BF = {}
local C_80_BF = {}
local C_80_9F = {}
local C_A0_BF = {}
local D_80_BF = {}
local D_80_8F = {}
local D_90_BF = {}
local E = {}

for i = 0x00, 0xFF do
  if i <= 0x7F then
    A[i] = A
  elseif i <= 0xC1 then
    A[i] = E
  elseif i <= 0xDF then
    A[i] = B_80_BF
  elseif i <= 0xEF then
    if i == 0xE0 then
      A[i] = C_A0_BF
    elseif i == 0xED then
      A[i] = C_80_9F
    else
      A[i] = C_80_BF
    end
  elseif i <= 0xF4 then
    if i == 0xF0 then
      A[i] = D_90_BF
    elseif i == 0xF4 then
      A[i] = D_80_8F
    else
      A[i] = D_80_BF
    end
  else
    A[i] = E
  end

  if 0x80 <= i and i <= 0xBF then
    B_80_BF[i] = A
    C_80_BF[i] = B_80_BF
    C_80_9F[i] = i <= 0x9F and B_80_BF or E
    C_A0_BF[i] = 0xA0 <= i and B_80_BF or E
    D_80_BF[i] = C_80_BF
    D_80_8F[i] = i <= 0x8F and C_80_BF or E
    D_90_BF[i] = 0x90 <= i and C_80_BF or E
  else
    B_80_BF[i] = E
    C_80_BF[i] = E
    C_80_9F[i] = E
    C_A0_BF[i] = E
    D_80_BF[i] = E
    D_80_8F[i] = E
    D_90_BF[i] = E
  end

  E[i] = E
end

return {
  S = A;
  E = E;
}
