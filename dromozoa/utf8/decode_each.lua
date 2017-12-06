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

local check_string = require "dromozoa.utf8.check_string"
local decode_table = require "dromozoa.utf8.decode_table"

local error = error
local byte = string.byte

local A = decode_table.A
local B = decode_table.B
local TA = decode_table.TA
local TB = decode_table.TB

return function (s)
  s = check_string(s, 1)

  local i = 1
  return function ()
    local j = i + 3
    local p = i
    local a, b, c, d = byte(s, i, j)
    local x = A[a]
    if x then
      if a <= 0xDF then
        if a <= 0x7F then
          i = i + 1
          return p, x
        else
          local b = TA[b]
          if b then
            i = i + 2
            return p, x + b
          end
        end
      else
        if a <= 0xEF then
          local b = B[a][b]
          local c = TA[c]
          if b and c then
            i = j
            return p, x + b + c
          end
        else
          local b = B[a][b]
          local c = TB[c]
          local d = TA[d]
          if b and c and d then
            i = i + 4
            return p, x + b + c + d
          end
        end
      end
      error "invalid UTF-8 code"
    elseif a then
      error "invalid UTF-8 code"
    end
  end
end
