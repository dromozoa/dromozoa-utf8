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

local encode = require "dromozoa.utf8.encode"

local error = error
local select = select
local type = type
local tonumber = tonumber
local concat = table.concat

return function (...)
  local n = select("#", ...)

  if n == 1 then
    local a = ...
    return encode(a)
  end

  local data = { ... }
  for i = 1, n do
    local a = data[i]
    local t = type(a)
    if t ~= "number" then
      if t == "string" then
        a = tonumber(a)
      end
    end
    if a % 1 ~= 0 then
      error("bad argument #" .. i .. " (number has no integer representation)")
    end

    local b = encode(a)
    if not b then
      error("bad argument #" .. i .. " (value out of range)")
    end
    data[i] = b
  end
  return concat(data)
end
