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

local encode_table = require "dromozoa.utf8.encode_table"

local error = error
local concat = table.concat

local A = encode_table.A
local B = encode_table.B
local C = encode_table.C
local T = encode_table.T

local function char(result, n, i, a, ...)
  if a then
    if a <= 0x07FF then
      n = n + 1
      result[n] = A[a]
      return char(result, n, i + 1, ...)
    elseif a <= 0xFFFF then
      local c = a % 0x40
      local a = (a - c) / 0x40
      local v = B[a]
      if v then
        n = n + 1
        result[n] = v
        n = n + 1
        result[n] = T[c]
        return char(result, n, i + 1, ...)
      end
    elseif a <= 0x10FFFF then
      local d = a % 0x40
      local a = (a - d) / 0x40
      local c = a % 0x40
      local a = (a - c) / 0x40
      local v = C[a]
      if v then
        n = n + 1
        result[n] = v
        n = n + 1
        result[n] = T[c]
        n = n + 1
        result[n] = T[d]
        return char(result, n, i + 1, ...)
      end
    end
    error("bad argument #" .. i)
  else
    return concat(result)
  end
end

return function (...)
  return char({}, 0, 1, ...)
end
