-- Copyright (C) 2018 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local builder = require "dromozoa.ucd.builder"

local unpack = table.unpack or unpack

local source_filename = "docs/10.0.0/ucd/UnicodeData.txt"
local code_filename = "dromozoa/ucd/general_category.lua"

local properties = {
  ["N"]  = true; -- neutral
  ["Na"] = true; -- narrow
  ["H"]  = true; -- halfwidth
  ["A"]  = true; -- ambiguous
  ["W"]  = true; -- wide
  ["F"]  = true; -- fullwidth
}

local _ = builder("Cn")

for line in io.lines(source_filename) do
  local code, name, generic_category = assert(line:match "^(%x+);(.-);(.-);")
  code = tonumber(code, 16)
  _:range(code, code, generic_category)
end

local data = _:build()

local out = assert(io.open(code_filename, "w"))
_.compile(out, data):close()
