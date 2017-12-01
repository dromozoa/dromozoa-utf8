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

local A = decoder.A
local B = decoder.B
local TA = decoder.TA
local TB = decoder.TB

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

  local result = 0
  while i <= j do
    local a, b, c, d = byte(s, i, i + 3)
    local x = A[a]
    if x then
      if a <= 0xDF then
        if a <= 0x7F then
          i = i + 1
        else
          local b = TA[b]
          if b then
            i = i + 2
          else
            return nil, i
          end
        end
      else
        if a <= 0xEF then
          local b = B[a][b]
          local c = TA[c]
          if b and c then
            i = i + 3
          else
            return nil, i
          end
        else
          local b = B[a][b]
          local c = TB[c]
          local d = TA[d]
          if b and c and d then
            i = i + 4
          else
            return nil, i
          end
        end
      end
    else
      return nil, i
    end
    result = result + 1
  end

  return result
end
