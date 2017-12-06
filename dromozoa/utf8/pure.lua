-- Copyright (C) 2015,2017 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local count = require "dromozoa.utf8.count"
local decode = require "dromozoa.utf8.decode"
local decode_each = require "dromozoa.utf8.decode_each"
local encode = require "dromozoa.utf8.encode"
local offset = require "dromozoa.utf8.offset"

return {
  char = encode;
  charpattern = "[\000-\127\194-\244][\128-\191]*";
  codes = decode_each;
  codepoint = decode;
  len = count;
  offset = offset;
}
