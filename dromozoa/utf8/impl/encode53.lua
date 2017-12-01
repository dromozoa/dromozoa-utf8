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

local encoder = require "dromozoa.utf8.encoder"

local A = encoder.A
local B = encoder.B
local C = encoder.C
local T = encoder.T

return function (a)
  if a <= 0x07FF then
    return A[a]
  elseif a <= 0xFFFF then
    local c = a & 0x3F
    local a = a >> 6
    local v = B[a]
    if v then
      return v .. T[c]
    end
  elseif a <= 0x10FFFF then
    local d = a & 0x3F
    local a = a >> 6
    local c = a & 0x3F
    local a = a >> 6
    local v = C[a]
    if v then
      return v .. T[c] .. T[d]
    end
  end
end
