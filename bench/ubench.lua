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

local pure = require "dromozoa.utf8.pure"

local unpack = table.unpack or unpack

local utf8_char = table.concat {
  string.char(0x41, 0xE2, 0x89, 0xA2, 0xCE, 0x91, 0x2E);
  string.char(0xED, 0x95, 0x9C, 0xEA, 0xB5, 0xAD, 0xEC, 0x96, 0xB4);
  string.char(0xE6, 0x97, 0xA5, 0xE6, 0x9C, 0xAC, 0xE8, 0xAA, 0x9E);
  string.char(0xEF, 0xBB, 0xBF, 0xF0, 0xA3, 0x8E, 0xB4);
}

local codepoint_source = {
  0x0041, 0x2262, 0x0391, 0x002E,
  0xD55C, 0xAD6D, 0xC5B4,
  0x65E5, 0x672C, 0x8A9E,
  0xFEFF, 0x0233B4,
}

local n = 5
utf8_char = utf8_char:rep(n)

local codepoint = {}
for _ = 1, n do
  for i = 1, #codepoint_source do
    codepoint[#codepoint + 1] = codepoint_source[i]
  end
end

local function run_char(x, f, ...)
  local result = f(...)
  return x + #result, f, ...
end

local function run_each(x, f, ...)
  for p, c in f(...) do
    x = x + p
  end
  return x, f, ...
end

local function run_codepoint(x, f, ...)
  local result = f(...)
  return x + result, f, ...
end

local function run_count(x, f, ...)
  local result = f(...)
  return x + result, f, ...
end

local function run_offset(x, f, ...)
  local result = f(...)
  return x + result, f, ...
end

local function setup(benchmarks, module, prefix)
  benchmarks[#benchmarks + 1] = { prefix .. ".char", run_char, 0, module.char, unpack(codepoint) }
  benchmarks[#benchmarks + 1] = { prefix .. ".codes", run_each, 0, module.codes, utf8_char }
  benchmarks[#benchmarks + 1] = { prefix .. ".codepoint", run_codepoint, 0, module.codepoint, utf8_char, 1, #utf8_char }
  benchmarks[#benchmarks + 1] = { prefix .. ".len", run_count, 0, module.len, utf8_char:rep(2) }
  benchmarks[#benchmarks + 1] = { prefix .. ".offset.P", run_offset, 0, module.offset, utf8_char, #codepoint }
  benchmarks[#benchmarks + 1] = { prefix .. ".offset.M", run_offset, 0, module.offset, utf8_char, -#codepoint }
end

local benchmarks = {}
setup(benchmarks, pure, "pure")
if utf8 then
  setup(benchmarks, utf8, "utf8")
end
return benchmarks
