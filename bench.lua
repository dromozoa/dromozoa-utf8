#! /usr/bin/env lua

local driver = require "impl2"
local pure = require "dromozoa.utf8.pure"

local data = table.concat {
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

local time = os.time
local difftime = os.difftime
local unpack = table.unpack or unpack

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
else
  print(posix_sys_time)
end

local n = 100000
-- local n = 1

--[[
local name = { "native", "pure", "decode1", "decode2", "decode3", "decode4", "decode5" }
for j = 1, #name do
  local x = 0
  local utf8_len = driver(name[j])
  local t1 = time()
  for i = 1, n do
    x = x + utf8_len(data)
  end
  local t2 = time()
  print(name[j], difftime(t2, t1), x)
end

local codes = { utf8.codes, pure.codes }
for i = 1, #codes do
  local x = 0
  local fn = codes[i]
  local t1 = time()
  for j = 1, n do
    for p, c in fn(data) do
      x = x + 1
    end
  end
  local t2 = time()
  print(difftime(t2, t1), x)
end
]]

local char = { utf8.char, pure.char }
for i = 1, #char do
  local x = 0
  local fn = char[i]
  local t1 = time()
  for j = 1, n do
    x = x + select("#", fn(unpack(codepoint)))
  end
  local t2 = time()
  print(difftime(t2, t1), x)
end
