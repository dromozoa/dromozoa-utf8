-- Copyright (C) 2017,2019 Tomoyuki Fujimori <moyu@dromozoa.com>
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
  local source = { byte(s, i, #s) }
  return function ()
    local source = source
    local j = i
    local a = source[j]
    local v = A[a]
    if v then
      if a <= 0xDF then
        if a <= 0x7F then
          i = j + 1
          return j, v
        else
          local b = TA[source[j + 1]]
          i = j + 2
          return j, v + b
        end
      else
        if a <= 0xEF then
          local b = B[a][source[j + 1]]
          local c = TA[source[j + 2]]
          i = j + 3
          return j, v + b + c
        else
          local b = B[a][source[j + 1]]
          local c = TB[source[j + 2]]
          local d = TA[source[j + 3]]
          i = j + 4
          return j, v + b + c + d
        end
      end
      error "invalid UTF-8 code"
    elseif a then
      error "invalid UTF-8 code"
    end
  end
end
