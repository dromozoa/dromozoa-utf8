// Copyright (C) 2017,2018,2023 Tomoyuki Fujimori <moyu@dromozoa.com>
//
// This file is part of dromozoa-utf8.
//
// dromozoa-utf8 is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// dromozoa-utf8 is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with dromozoa-utf8. If not, see <https://www.gnu.org/licenses/>.

package com.dromozoa.utf8;

import org.junit.jupiter.api.Test;

public class ApplicationTest {
  @Test
  public void testEastAsianWidth() {
    String[] args = { "EAST_ASIAN_WIDTH", "3000", "30FF" };
    Application.main(args);
  }

  @Test
  public void testWhiteSpace() {
    String[] args = { "WHITE_SPACE", "2000", "20FF" };
    Application.main(args);
  }

  @Test
  public void testGeneralCategory() {
    String[] args = { "GENERAL_CATEGORY", "2000", "200F" };
    Application.main(args);
  }
}
