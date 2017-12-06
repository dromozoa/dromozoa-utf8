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
local decode_impl = require "dromozoa.utf8.decode_impl"

local error = error
local concat = table.concat
local unpack = table.unpack or unpack

local data = {}

return function (s, i, j)
  s = check_string(s, 1)

  local n = #s
  local m = n + 1

  if i == nil then
    i = 1
  else
    i = check_integer(i, 2)
    if i < 0 then
      i = i + m
    end
  end

  if j == nil then
    j = i
  else
    j = check_integer(j, 3)
    if j < 0 then
      j = j + m
    end
  end

  if i < 1 then
    error "bad argument #2 (out of range)"
  end
  if n < j then
    error "bad argument #3 (out of range)"
  end

  if i == j then
    local a, b = decode_impl(s, i)
    return b
  else
    local k = 0
    while i <= j do
      k = k + 1
      i, data[k] = decode_impl(s, i)
    end
    return unpack(data, 1, k)
  end
end
