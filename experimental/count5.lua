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

local decoder = require "dromozoa.utf8.decoder"

local byte = string.byte

local A = {}
local B = {}
local C = {}
local C_80_9F = {}
local C_A0_BF = {}
local D = {}
local D_80_8F = {}
local D_90_BF = {}

for i = 0x00, 0xFF do
  if i <= 0x7F then
    A[i] = A
  elseif i <= 0xC1 then
    A[i] = false -- error
  elseif i <= 0xDF then
    A[i] = B
  elseif i <= 0xEF then
    if i == 0xE0 then
      A[i] = C_A0_BF
    elseif i == 0xED then
      A[i] = C_80_9F
    else
      A[i] = C
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
    A[i] = false
  end
end

for i = 0x00, 0xFF do
  if 0x80 <= i and i <= 0xBF then
    B[i] = A
    C[i] = B
    C_80_9F[i] = i <= 0x9F and B
    C_A0_BF[i] = 0xA0 <= i and B
    D[i] = C
    D_80_8F[i] = i <= 0x8F and C
    D_90_BF[i] = 0x90 <= i and C
  else
    B[i] = false
    C[i] = false
    C_80_9F[i] = false
    C_A0_BF[i] = false
    D[i] = false
    D_80_8F[i] = false
    D_90_BF[i] = false
  end
end

return function (s, i, j)
  local n = #s

  if i == nil then
    i = 1
  else
    local m = n + 1
    if i < 0 then
      i = m + i
    end
    if i < 1 or m < i then
      error "bad argument #2"
    end
  end

  if j == nil then
    j = n
  else
    if j < 0 then
      j = n + 1 + j
    end
    if #s < j then
      error "bad argument #3"
    end
  end

  local s1 = A
  local result = 0
  for i = i + 3, j, 4 do
    local a, b, c, d = byte(s, i - 3, i)
    local s2 = s1[a]
    local s3 = s2[b]
    local s4 = s3[c]
    s1 = s4[d]
    if s1 == A then result = result + 1 end
    if s2 == A then result = result + 1 end
    if s3 == A then result = result + 1 end
    if s4 == A then result = result + 1 end
  end

  local p = j + 1
  local m = p - (p - i) % 4
  if m < p then
    local a, b, c = byte(s, m, n)
    if c then
      local s2 = s1[a]
      local s3 = s2[b]
      local s4 = s3[c]
      if s2 == A then result = result + 1 end
      if s3 == A then result = result + 1 end
      if s4 == A then result = result + 1 end
    elseif b then
      local s2 = s1[a]
      local s3 = s2[b]
      if s2 == A then result = result + 1 end
      if s3 == A then result = result + 1 end
    else
      local s2 = s1[a]
      if s2 == A then result = result + 1 end
    end
  end

  return result
end
