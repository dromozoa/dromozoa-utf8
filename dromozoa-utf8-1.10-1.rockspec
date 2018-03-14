package = "dromozoa-utf8"
version = "1.10-1"
source = {
  url = "https://github.com/dromozoa/dromozoa-utf8/archive/v1.10.tar.gz";
  file = "dromozoa-utf8-1.10.tar.gz";
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
    ["dromozoa.ucd"] = "dromozoa/ucd.lua";
    ["dromozoa.ucd.builder"] = "dromozoa/ucd/builder.lua";
    ["dromozoa.ucd.east_asian_width"] = "dromozoa/ucd/east_asian_width.lua";
    ["dromozoa.ucd.general_category"] = "dromozoa/ucd/general_category.lua";
    ["dromozoa.ucd.is_white_space"] = "dromozoa/ucd/is_white_space.lua";
    ["dromozoa.utf16"] = "dromozoa/utf16.lua";
    ["dromozoa.utf16.decode_surrogate_pair"] = "dromozoa/utf16/decode_surrogate_pair.lua";
    ["dromozoa.utf8"] = "dromozoa/utf8.lua";
    ["dromozoa.utf8.check_integer"] = "dromozoa/utf8/check_integer.lua";
    ["dromozoa.utf8.check_string"] = "dromozoa/utf8/check_string.lua";
    ["dromozoa.utf8.count"] = "dromozoa/utf8/count.lua";
    ["dromozoa.utf8.count_table"] = "dromozoa/utf8/count_table.lua";
    ["dromozoa.utf8.decode"] = "dromozoa/utf8/decode.lua";
    ["dromozoa.utf8.decode_each"] = "dromozoa/utf8/decode_each.lua";
    ["dromozoa.utf8.decode_table"] = "dromozoa/utf8/decode_table.lua";
    ["dromozoa.utf8.encode"] = "dromozoa/utf8/encode.lua";
    ["dromozoa.utf8.encode53"] = "dromozoa/utf8/encode53.lua";
    ["dromozoa.utf8.encode_error"] = "dromozoa/utf8/encode_error.lua";
    ["dromozoa.utf8.encode_table"] = "dromozoa/utf8/encode_table.lua";
    ["dromozoa.utf8.offset"] = "dromozoa/utf8/offset.lua";
    ["dromozoa.utf8.offset_table"] = "dromozoa/utf8/offset_table.lua";
    ["dromozoa.utf8.pure"] = "dromozoa/utf8/pure.lua";
  };
  install = {
    bin = {
      ["dromozoa-markdown-table"] = "dromozoa-markdown-table";
    };
  };
}
