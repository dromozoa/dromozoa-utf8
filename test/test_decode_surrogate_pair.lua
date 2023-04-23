-- Copyright (C) 2017,2018 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local utf16 = require "dromozoa.utf16"

local function check_error(a, b, expect)
  local result, message = pcall(utf16.decode_surrogate_pair, a, b)
  assert(not result)
  assert(message:find(expect, nil, true))
end

check_error(0x0000, 0x0000, "bad argument #1")
check_error(0xD7FF, 0x0000, "bad argument #1")
check_error(0xDC00, 0x0000, "bad argument #1")
check_error(0xFFFF, 0x0000, "bad argument #1")

check_error(0xD800, 0x0000, "bad argument #2")
check_error(0xD800, 0xDBFF, "bad argument #2")
check_error(0xD800, 0xE000, "bad argument #2")
check_error(0xD800, 0xFFFF, "bad argument #2")

-- U+10000 (DBC0 DC00)
assert(utf16.decode_surrogate_pair(0xD800, 0xDC00) == 0x010000)
-- U+1F37A (D83C DF7A) BEER MUG
assert(utf16.decode_surrogate_pair(0xD83C, 0xDF7A) == 0x01F37A)
-- U+1F37B (D83C DF7B) CLINKING BEER MUGS
assert(utf16.decode_surrogate_pair(0xD83C, 0xDF7B) == 0x01F37B)
-- U+100000 (DBC0 DC00)
assert(utf16.decode_surrogate_pair(0xDBC0, 0xDC00) == 0x100000)
assert(utf16.decode_surrogate_pair(0xDBFF, 0xDFFF) == 0x10FFFF)
