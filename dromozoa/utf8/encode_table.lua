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

local char = string.char

local A = {}
local B = {}
local C = {}
local T = {}

for i = 0x0000, 0x007F do
  A[i] = char(i)
end
for i = 0x0080, 0x07FF do
  local b = i % 0x40
  local a = (i - b) / 0x40
  A[i] = char(a + 0xC0, b + 0x80)
end

for i = 0x0000, 0x001F do
  B[i] = false
end
for i = 0x0020, 0x03FF do
  if 0x0360 <= i and i <= 0x037F then
    B[i] = false
  else
    local b = i % 0x40
    local a = (i - b) / 0x40
    B[i] = char(a + 0xE0, b + 0x80)
  end
end

for i = 0x0000, 0x000F do
  C[i] = false
end
for i = 0x0010, 0x010F do
  local b = i % 0x40
  local a = (i - b) / 0x40
  C[i] = char(a + 0xF0, b + 0x80)
end

for i = 0x0000, 0x003F do
  T[i] = char(i + 0x80)
end

return {
  A = A;
  B = B;
  C = C;
  T = T;
}
