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

local check_integer = require "dromozoa.utf8.check_integer"
local check_string = require "dromozoa.utf8.check_string"
local decode_table = require "dromozoa.utf8.decode_table"

local error = error
local byte = string.byte
local unpack = table.unpack or unpack

local A = decode_table.A
local B = decode_table.B
local TA = decode_table.TA
local TB = decode_table.TB

return function (s, i, j)
  s = check_string(s, 1)

  local n = #s
  local m = n + 1

  if i == nil then
    i = 1
  else
    i = check_integer(i, 2)
    if i < 0 then
      i = i + m
    end
  end

  if j == nil then
    j = i
  else
    j = check_integer(j, 3)
    if j < 0 then
      j = j + m
    end
  end

  if i < 1 then
    error "bad argument #2 (out of range)"
  end
  if n < j then
    error "bad argument #3 (out of range)"
  end

  if i == j then
    local a, b, c, d = byte(s, i, i + 3)
    local v = A[a]
    if v then
      if a <= 0xDF then
        if a <= 0x7F then
          return v
        else
          local b = TA[b]
          if b then
            return v + b
          end
        end
      else
        if a <= 0xEF then
          local b = B[a][b]
          local c = TA[c]
          if b and c then
            return v + b + c
          end
        else
          local b = B[a][b]
          local c = TB[c]
          local d = TA[d]
          if b and c and d then
            return v + b + c + d
          end
        end
      end
      error "invalid UTF-8 code"
    elseif a then
      error "invalid UTF-8 code"
    end
  else
    local data = {}
    local k = 0
    while i <= j do
      k = k + 1
      local j = i + 3
      local a, b, c, d = byte(s, i, j)
      local v = A[a]
      if v then
        if a <= 0xDF then
          if a <= 0x7F then
            i = i + 1
            data[k] = v
          else
            local b = TA[b]
            if b then
              i = i + 2
              data[k] = v + b
            else
              error "invalid UTF-8 code"
            end
          end
        else
          if a <= 0xEF then
            local b = B[a][b]
            local c = TA[c]
            if b and c then
              i = j
              data[k] = v + b + c
            else
              error "invalid UTF-8 code"
            end
          else
            local b = B[a][b]
            local c = TB[c]
            local d = TA[d]
            if b and c and d then
              i = i + 4
              data[k] = v + b + c + d
            else
              error "invalid UTF-8 code"
            end
          end
        end
      elseif a then
        error "invalid UTF-8 code"
      end
    end
    return unpack(data)
  end
end
