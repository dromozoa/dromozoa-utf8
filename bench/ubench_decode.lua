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

local decode = require "experimental.decode"
local decode2 = require "experimental.decode2"
local decode3 = require "experimental.decode3"
local decode4 = require "experimental.decode4"

local utf8_char = string.char(
    0x41,
    0xE2, 0x89, 0xA2,
    0xCE, 0x91,
    0x2E,
    0xED, 0x95, 0x9C,
    0xEA, 0xB5, 0xAD,
    0xEC, 0x96, 0xB4,
    0xE6, 0x97, 0xA5,
    0xE6, 0x9C, 0xAC,
    0xE8, 0xAA, 0x9E,
    0xEF, 0xBB, 0xBF,
    0xF0, 0xA3, 0x8E, 0xB4);

local codepoint = {
  0x0041, 0x2262, 0x0391, 0x002E,
  0xD55C, 0xAD6D, 0xC5B4,
  0x65E5, 0x672C, 0x8A9E,
  0xFEFF, 0x0233B4,
}

local n = 100
local data = utf8_char:rep(n)

local function run(f, x, ...)
  local result = f(...)
  return f, x + result, ...
end

local algorithms = {
  decode;
  decode2;
  decode3;
  decode4;
}

local benchmarks = {}
for i = 1, #algorithms do
  run(algorithms[i], 0, data, 1, #data)
  benchmarks[("%02d"):format(i)] = { run, algorithms[i], 0, data, 1, #data }
end
return benchmarks
