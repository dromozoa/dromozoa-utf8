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

local error = error
local tonumber = tonumber
local type = type

return function (v, i)
  local t = type(v)
  if t ~= "number" then
    if t == "string" then
      v = tonumber(v)
      if not v then
        error("bad argument #" .. i .. " (number expected, got " .. t .. ")")
      end
    else
      error("bad argument #" .. i .. " (number expected, got " .. t .. ")")
    end
  end
  if v % 1 ~= 0 then
    error("bad argument #" .. i .. " (number has no integer representation)")
  end
  return v
end
