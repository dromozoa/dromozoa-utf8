package com.dromozoa.utf8;

import java.util.*;
import com.ibm.icu.lang.*;

public class Application {
  private static class Range {
    public int first;
    public int last;
    public int property;

    public Range(int first, int last, int property) {
      this.first = first;
      this.last = last;
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
      Range range = null;
      if (!ranges.isEmpty()) {
        range = ranges.get(ranges.size() - 1);
        if (range.property != property) {
          range = null;
        }
      }
      if (range == null) {
        ranges.add(new Range(codePoint, codePoint, property));
      } else {
        range.last = codePoint;
      }
    }

    for (Range range : ranges) {
      System.out.println(range.first + "\t" + range.last + "\t" + getPropertyString(range.property));
    }
  }
}
