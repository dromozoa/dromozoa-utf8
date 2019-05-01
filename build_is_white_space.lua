-- Copyright (C) 2018,2019 Tomoyuki Fujimori <moyu@dromozoa.com>
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
local build_config = require "build_config"

local unpack = table.unpack or unpack

local source_filename = "docs/" .. build_config.ucd_version .. "/ucd/PropList.txt"
local result_filename = "dromozoa/ucd/is_white_space.lua"

local _ = builder(false)

for line in io.lines(source_filename) do
  local first, last, property = line:match "^(%x+)%.%.(%x+)%s*;%s*([%w_]+)"
  if not first then
    first, property = line:match "^(%x+)%s*;%s*([%w_]+)"
    last = first
  end
  if first and property == "White_Space" then
    local first = tonumber(first, 16)
    local last = tonumber(last, 16)
    assert(first <= last)
    assert(not prev or prev < first)
    _:range(first, last, true)
    prev = last
  end
end

local data = _:build()
local out = assert(io.open(result_filename, "w"))
_.compile(out, data):close()
