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

local encode_error = require "dromozoa.utf8.encode_error"
local encode_table = require "dromozoa.utf8.encode_table"

local select = select
local concat = table.concat

local A = encode_table.A
local B = encode_table.B
local C = encode_table.C
local T = encode_table.T

return function (...)
  local n = select("#", ...)
  if n == 1 then
    local a = ... + 0
    if a <= 0x07FF then
      local v = A[a]
      if v then
        return v
      end
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
    encode_error(..., 1)
  else
    local data = {...}
    for i = 1, n do
      local a = data[i] + 0
      if a <= 0x07FF then
        local v = A[a]
        if v then
          data[i] = v
        else
          encode_error(data[i], i)
        end
      elseif a <= 0xFFFF then
        local c = a & 0x3F
        local a = a >> 6
        local v = B[a]
        if v then
          data[i] = v .. T[c]
        else
          encode_error(data[i], i)
        end
      elseif a <= 0x10FFFF then
        local d = a & 0x3F
        local a = a >> 6
        local c = a & 0x3F
        local a = a >> 6
        local v = C[a]
        if v then
          data[i] = v .. T[c] .. T[d]
        else
          encode_error(data[i], i)
        end
      else
        encode_error(data[i], i)
      end
    end
    return concat(data)
  end
end
