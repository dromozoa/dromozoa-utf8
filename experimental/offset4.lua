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

local error = error
local byte = string.byte

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

return function (s, n, i)
  if n == nil then
    error "bad argument #2"
  end

  if i == nil then
    if n < 0 then
      i = #s + 1
    else
      i = 1
    end
  else
    if i < 0 then
      i = #s + 1 + i
    end
    if i < 1 or #s + 1 < i then
      error "bad argument #3"
    end
  end

  if n == 0 then
    local a = byte(s, i)
    while a ~= nil and 0x80 <= a and a <= 0xBF do
      i = i - 1
      a = s:byte(i)
    end
  else
    if n < 0 then
      local a = byte(s, i)
      if a ~= nil and 0x80 <= a and a <= 0xBF then
        error "initial position is a continuation byte"
      end
      while n < 0 do
        repeat
          i = i - 1
          a = s:byte(i)
          if a == nil then return nil end
        until a < 0x80 or 0xBF < a
        n = n + 1
      end
    else
      local a = byte(s, i)
      if a == nil then
        error "initial position is invalid"
      end
      if 0x80 <= a and a <= 0xBF then
        error "initial position is a continuation byte"
      end
      while n > 1 do
        i = i + H[a]
        a = byte(s, i)
        n = n - 1
      end
      return i
    end
  end
  return i
end
