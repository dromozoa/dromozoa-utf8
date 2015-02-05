package = "dromozoa-utf8"
version = "1.2-1"
source = {
  url = "https://github.com/dromozoa/dromozoa-utf8/archive/v1.2.tar.gz";
  file = "dromozoa-utf8-1.2.tar.gz";
}
description = {
  summary = "Lua 5.3 compatible pure-Lua UTF-8 implementation";
  license = "GPL-3";
  homepage = "https://github.com/dromozoa/dromozoa-utf8/";
  maintainer = "Tomoyuki Fujimori <moyu@dromozoa.com>";
}
build = {
  type = "builtin";
  modules = {
    ["dromozoa.utf8"] = "dromozoa/utf8.lua";
    ["dromozoa.utf8.pure"] = "dromozoa/utf8/pure.lua";
  };
}
