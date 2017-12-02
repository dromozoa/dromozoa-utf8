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
local concat = table.concat

local function char(result, n, a, ...)
  if a then
    local b = encode(a)
    if not b then
      error("bad argument #" .. n)
    end
    result[n] = b
    return char(result, n + 1, ...)
  else
    return concat(result)
  end
end

return function (...)
  return char({}, 1, ...)
end
