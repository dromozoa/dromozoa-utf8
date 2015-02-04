#! /usr/bin/env lua

local pure = require "dromozoa.utf8.pure"
local difftime = os.difftime
local time = os.time
local unpack = table.unpack or unpack

local utf8_char = table.concat {
  string.char(0x41, 0xE2, 0x89, 0xA2, 0xCE, 0x91, 0x2E);
  string.char(0xED, 0x95, 0x9C, 0xEA, 0xB5, 0xAD, 0xEC, 0x96, 0xB4);
  string.char(0xE6, 0x97, 0xA5, 0xE6, 0x9C, 0xAC, 0xE8, 0xAA, 0x9E);
  string.char(0xEF, 0xBB, 0xBF, 0xF0, 0xA3, 0x8E, 0xB4);
}

local codepoint = {
  0x0041, 0x2262, 0x0391, 0x002E,
  0xD55C, 0xAD6D, 0xC5B4,
  0x65E5, 0x672C, 0x8A9E,
  0xFEFF, 0x0233B4,
}

local result, posix_sys_time = pcall(require, "posix.sys.time")
if result then
  time = posix_sys_time.gettimeofday
  difftime = function (t2, t1)
    local sec = t2.tv_sec - t1.tv_sec
    if t2.tv_usec < t1.tv_usec then
      return (sec - 1) + (1000000 + t2.tv_usec - t1.tv_usec) * 0.000001
    else
      return sec + (t2.tv_usec - t1.tv_usec) * 0.000001
    end
  end
end

local n = tonumber(arg[1]) or 100000

local function bench(name, fn)
  local t1 = time()
  fn(utf8[name], n)
  local t2 = time()
  local t = difftime(t2, t1)

  local t1 = time()
  fn(pure[name], n)
  local t2 = time()
  local u = difftime(t2, t1)

  print(name, t, u, u / t)
end

print("name", "utf8", "pure")

bench("char", function (fn, n)
  local x = 0
  for i = 1, n do
    x = x + select("#", fn(unpack(codepoint)))
  end
end)

bench("codes", function (fn, n)
  local x = 0
  for i = 1, n do
    for p, c in fn(utf8_char) do
      x = x + 1
    end
  end
end)

bench("len", function (fn, n)
  local x = 0
  for i = 1, n do
    x = x + fn(utf8_char)
  end
end)

bench("offset", function (fn, n)
  local x = 0
  for i = 1, n do
    x = x + fn(utf8_char, -1)
  end
end)
