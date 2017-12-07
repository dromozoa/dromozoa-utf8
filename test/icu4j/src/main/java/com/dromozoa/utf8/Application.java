// Copyright (C) 2017 Tomoyuki Fujimori <moyu@dromozoa.com>
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
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with dromozoa-utf8.  If not, see <http://www.gnu.org/licenses/>.

package com.dromozoa.utf8;

import java.util.*;
import com.ibm.icu.lang.*;

public class Application {
  private static class Range {
    public final int first;
    public int last;
    public final int property;

    public Range(int codePoint, int property) {
      first = codePoint;
      last = codePoint;
      this.property = property;
    }
  }

  private static String getPropertyString(int property) {
    switch (property) {
      case UCharacter.EastAsianWidth.AMBIGUOUS:
        return "A";
      case UCharacter.EastAsianWidth.FULLWIDTH:
        return "F";
      case UCharacter.EastAsianWidth.HALFWIDTH:
        return "H";
      case UCharacter.EastAsianWidth.NEUTRAL:
        return "N";
      case UCharacter.EastAsianWidth.NARROW:
        return "Na";
      case UCharacter.EastAsianWidth.WIDE:
        return "W";
      default:
        throw new RuntimeException();
    }
  }

  public static void main(String[] args) {
    int codePointFirst = 0;
    int codePointLast = 0x10FFFF;

    if (args != null) {
      if (args.length > 0) {
        codePointFirst = Integer.parseInt(args[0], 16);
      }
      if (args.length > 1) {
        codePointLast = Integer.parseInt(args[1], 16);
      }
    }

    List<Range> ranges = new ArrayList<>();
    for (int codePoint = codePointFirst; codePoint <= codePointLast; ++codePoint) {
      int property = UCharacter.getIntPropertyValue(codePoint, UProperty.EAST_ASIAN_WIDTH);
      if (!ranges.isEmpty()) {
        Range range = ranges.get(ranges.size() - 1);
        if (range.property == property) {
          if (range.last != codePoint - 1) {
            throw new RuntimeException();
          }
          range.last = codePoint;
          continue;
        }
      }
      ranges.add(new Range(codePoint, property));
    }

    for (Range range : ranges) {
      System.out.println(range.first + "\t" + range.last + "\t" + getPropertyString(range.property));
    }
  }
}
