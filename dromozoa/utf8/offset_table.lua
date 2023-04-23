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

local H = {}
local T = {}

for i = 0x00, 0xFF do
  if i <= 0x7F then
    H[i] = 1
  elseif i <= 0xC1 then
    H[i] = false
  elseif i <= 0xDF then
    H[i] = 2
  elseif i <= 0xEF then
    H[i] = 3
  elseif i <= 0xF4 then
    H[i] = 4
  else
    H[i] = false
  end
  T[i] = 0x80 <= i and i <= 0xBF
end

return {
  H = H;
  T = T;
}
