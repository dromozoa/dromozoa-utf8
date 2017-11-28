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

return function (s, i)
  local a, b, c, d = s:byte(i, i + 3)
  if a == nil then
    return nil
  elseif a <= 0x7F then
    return i + 1, a
  elseif 0xC2 <= a then
    if a <= 0xDF then
      if b == nil or b < 0x80 or 0xBF < b then return nil end
      local a = a % 0x20 * 0x40
      local b = b % 0x40
      return i + 2, a + b
    elseif a <= 0xEF then
      if a <= 0xEC then
        if a == 0xE0 then
          if b == nil or b < 0xA0 or 0xBF < b then return nil end
        else
          if b == nil or b < 0x80 or 0xBF < b then return nil end
        end
      else
        if a == 0xED then
          if b == nil or b < 0x80 or 0x9F < b then return nil end
        else
          if b == nil or b < 0x80 or 0xBF < b then return nil end
        end
      end
      if c == nil or c < 0x80 or 0xBF < c then return nil end
      local a = a % 0x10 * 0x1000
      local b = b % 0x40 * 0x40
      local c = c % 0x40
      return i + 3, a + b + c
    elseif a <= 0xF4 then
      if a == 0xF0 then
        if b == nil or b < 0x90 or 0xBF < b then return nil end
      elseif a <= 0xF3 then
        if b == nil or b < 0x80 or 0xBF < b then return nil end
      else
        if b == nil or b < 0x80 or 0x8F < b then return nil end
      end
      if c == nil or c < 0x80 or 0xBF < c then return nil end
      if d == nil or d < 0x80 or 0xBF < d then return nil end
      local a = a % 0x08 * 0x040000
      local b = b % 0x40 * 0x1000
      local c = c % 0x40 * 0x40
      local d = d % 0x40
      return i + 4, a + b + c + d
    end
  end
  return nil
end

