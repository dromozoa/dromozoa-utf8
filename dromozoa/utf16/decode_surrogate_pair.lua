-- Copyright (C) 2017,2023 Tomoyuki Fujimori <moyu@dromozoa.com>
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
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-utf8. If not, see <https://www.gnu.org/licenses/>.

local error = error

return function (a, b)
  if a < 0xD800 or 0xDBFF < a then
    error "bad argument #1 (value out of high surrogate area)"
  end
  if b < 0xDC00 or 0xDFFF < b then
    error "bad argument #2 (value out of low surrogate area)"
  end
  return (a - 0xD800) * 0x0400 + (b - 0xDC00) + 0x010000
end
