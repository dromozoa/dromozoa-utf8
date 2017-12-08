#! /bin/sh -e

# Copyright (C) 2017 Tomoyuki Fujimori <moyu@dromozoa.com>
#
# This file is part of dromozoa-utf8.
#
# dromozoa-utf8 is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# dromozoa-utf8 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with dromozoa-utf8.  If not, see <http://www.gnu.org/licenses/>.

case x$1 in
  x) lua=lua;;
  *) lua=$1;;
esac

for i in test/test*.lua
do
  "$lua" "$i"
done

mkdir -p out

case x$TMPDIR in
  x) TMPDIR=/tmp;;
esac
"$lua" dromozoa-markdown-table <test/table.md >out/table.md
diff -u test/table.exp out/table.md

rm -f -r out
