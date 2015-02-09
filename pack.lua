#! /usr/bin/env lua

io.write [[
-- This file was auto-generated.
]]

for i = 1, #arg do
  local path = arg[i]
  local name = arg[i]:gsub("/", "."):gsub("%.lua$", "")

  local handle = assert(io.open(path))
  local chunk = handle:read("*a"):gsub("%s+$", "")
  handle:close()

  io.write(string.format([[
package.loaded[%q] = (function ()
-- ===========================================================================
-- %s
-- ===========================================================================
%s
-- ===========================================================================
end)()
]], name, name, chunk))
end
