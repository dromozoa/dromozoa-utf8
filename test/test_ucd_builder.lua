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

local utf8 = require "dromozoa.utf8"
local builder = require "dromozoa.ucd.builder"

local loadstring = loadstring or load

local alnum = builder(false)
alnum:range(0x30, 0x39, true)
alnum:range(0x41, 0x5A, true)
alnum:range(0x61, 0x7A, true)
local data = alnum:build()
local code = builder.compile(data)

io.write(table.concat(code))

local f = assert(loadstring(table.concat(code)))()
assert(f(utf8.codepoint("0")))
assert(f(utf8.codepoint("A")))
assert(f(utf8.codepoint("a")))
assert(not f(utf8.codepoint(" ")))
assert(not f(utf8.codepoint("あ")))
