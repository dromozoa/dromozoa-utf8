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

local offset_table = require "dromozoa.utf8.offset_table"

local error = error
local byte = string.byte

local H = offset_table.H
local T = offset_table.T

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
    return i
  elseif n < 0 then
    if n == -1 then
      local a = byte(s, i)
      if T[a] then
        error "initial position is a continuation byte"
      end
      i = i - 1
      if i > 3 then
        local a, b, c, d = byte(s, i - 3, i)
        if not T[d] then
          -- noop
        elseif not T[c] then
          i = i - 1
        elseif not T[b] then
          i = i - 2
        elseif not T[a] then
          i = i - 3
        else
          error "invalid UTF-8"
        end
      else
        local a, b, c = byte(s, 1, i)
        if c and not T[c] then
          -- noop
          i = 3
        elseif b and not T[b] then
          i = 2
        elseif a and not T[a] then
          i = 1
        else
          return
        end
      end
      return i
    else
      local a = byte(s, i)
      if T[a] then
        error "initial position is a continuation byte"
      end
      i = i - 1
      for i = i, 4, -4 do
        local a, b, c, d = byte(s, i - 3, i)
        if not T[d] then
          n = n + 1 if n == 0 then return i end
        end
        if not T[c] then
          n = n + 1 if n == 0 then return i - 1 end
        end
        if not T[b] then
          n = n + 1 if n == 0 then return i - 2 end
        end
        if not T[a] then
          n = n + 1 if n == 0 then return i - 3 end
        end
      end
      local p = i % 4
      if p > 0 then
        local a, b, c = byte(s, 1, p)
        if c then
          if not T[c] then
            n = n + 1 if n == 0 then return 3 end
          end
          if not T[b] then
            n = n + 1 if n == 0 then return 2 end
          end
          if not T[a] then
            n = n + 1 if n == 0 then return 1 end
          end
        elseif b then
          if not T[b] then
            n = n + 1 if n == 0 then return 2 end
          end
          if not T[a] then
            n = n + 1 if n == 0 then return 1 end
          end
        elseif a then
          if not T[a] then
            n = n + 1 if n == 0 then return 1 end
          end
        else
          error "???"
        end
      else
        return
      end
    end
  else
    if n == 1 then
      local a = byte(s, i)
      if T[a] then
        error "initial position is a continuation byte"
      end
      return i
    else
      local a = byte(s, i)
      if T[a] then
        error "initial position is a continuation byte"
      end
      repeat
        local x = H[a]
        if not x then
          return
        end
        i = i + x
        n = n - 1
        a = byte(s, i)
      until n == 1
      return i
    end
  end
end
