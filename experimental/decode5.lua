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

local H1 = decoder.A
local H2 = decoder.B
local TA_80_BF = decoder.TA
local TB_80_BF = decoder.TB
local TC_80_BF = decoder.TC

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
