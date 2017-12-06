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
local encode_impl = require "dromozoa.utf8.encode_impl"

local error = error
local select = select
local concat = table.concat

return function (...)
  local n = select("#", ...)
  if n == 1 then
    local v = encode_impl(check_integer(..., 1))
    if not v then
      error "bad argument #1 (value out of range)"
    else
      return v
    end
  else
    local data = {...}
    for i = 1, n do
      local v = encode_impl(check_integer(data[i], i))
      if not v then
        error("bad argument #" .. i .. " (value out of range)")
      else
        data[i] = v
      end
    end
    return concat(data)
  end
end
