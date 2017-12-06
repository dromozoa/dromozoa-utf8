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

local check_integer = require "dromozoa.utf8.check_integer"
local check_string = require "dromozoa.utf8.check_string"
local offset_table = require "dromozoa.utf8.offset_table"

local error = error
local byte = string.byte

local H = offset_table.H
local T = offset_table.T

return function (s, n, i)
  s = check_string(s, 1)
  n = check_integer(n, 2)

  local m = #s + 1

  if i == nil then
    if n < 0 then
      i = m
    else
      i = 1
    end
  else
    i = check_integer(i, 3)
    if i < 0 then
      i = i + m
    end
  end

  if i < 1 or m < i then
    error "bad argument #3 (position out of range)"
  end

  if n == 0 then
    if i == m then
      return i
    elseif i > 3 then
      local j = i - 3
      local a, b, c, d = byte(s, j, i)
      if H[d] then return i end
      if H[c] then return i - 1 end
      if H[b] then return i - 2 end
      if H[a] then return j end
    else
      local a, b, c = byte(s, 1, i)
      if H[c] then return 3 end
      if H[b] then return 2 end
      if H[a] then return 1 end
    end
  elseif n < 0 then
    local a = byte(s, i)
    if T[a] then
      error "initial position is a continuation byte"
    end
    i = i - 1
    for i = i, 4, -4 do
      local j = i - 3
      local a, b, c, d = byte(s, j, i)
      if H[d] then n = n + 1 if n == 0 then return i end end
      if H[c] then n = n + 1 if n == 0 then return i - 1 end end
      if H[b] then n = n + 1 if n == 0 then return i - 2 end end
      if H[a] then n = n + 1 if n == 0 then return j end end
    end
    local a, b, c = byte(s, 1, i % 4)
    if H[c] then n = n + 1 if n == 0 then return 3 end end
    if H[b] then n = n + 1 if n == 0 then return 2 end end
    if H[a] then n = n + 1 if n == 0 then return 1 end end
  else
    local a = byte(s, i)
    if T[a] then
      error "initial position is a continuation byte"
    end
    if n == 1 then
      return i
    end
    for n = n, 3, -1 do
      local x = H[a]
      if not x then
        return
      else
        i = i + x
        a = byte(s, i)
      end
    end
    local x = H[a]
    if not x then
      return
    else
      return i + x
    end
  end
end
