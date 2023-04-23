-- Copyright (C) 2017,2019,2020 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local check_integer = require "dromozoa.utf8.check_integer"
local check_string = require "dromozoa.utf8.check_string"
local counter_table = require "dromozoa.utf8.count_table"

local byte = string.byte

local S = counter_table.S
local E = counter_table.E

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
    j = n
  else
    j = check_integer(j, 3)
    if j < 0 then
      j = j + m
    end
  end

  if i < 1 or m < i then
    error "bad argument #2 (initial position out of bounds)"
  end
  if n < j then
    error "bad argument #3 (final position out of bounds)"
  end
  if j < i then
    return 0
  end

  local s1 = S
  local count = 0
  for i = i + 3, j, 4 do
    if s1 == S then count = count + 1 end
    local a, b, c, d = byte(s, i - 3, i)
    local s2 = s1[a]
    local s3 = s2[b]
    local s4 = s3[c]
    s1 = s4[d]
    if s1 == E then
      if s2 == E then return nil, i - 3 end
      if s3 == E then return nil, i - 2 end
      if s4 == E then return nil, i - 1 end
      return nil, i
    end
    if s2 == S then count = count + 1 end
    if s3 == S then count = count + 1 end
    if s4 == S then count = count + 1 end
  end

  local p = j + 1
  local m = p - (p - i) % 4
  if m < p then
    if s1 == S then count = count + 1 end
    local a, b, c = byte(s, m, j)
    if c then
      local s2 = s1[a]
      local s3 = s2[b]
      local s4 = s3[c]
      if s4 == E then
        if s2 == E then return nil, j - 2 end
        if s3 == E then return nil, j - 1 end
        return nil, j
      end
      if s2 == S then count = count + 1 end
      if s3 == S then count = count + 1 end
    elseif b then
      local s2 = s1[a]
      local s3 = s2[b]
      if s3 == E then
        if s2 == E then return nil, j - 1 end
        return nil, j
      end
      if s2 == S then count = count + 1 end
    else
      local s2 = s1[a]
      if s2 == E then return nil, j end
    end
  end

  return count
end
