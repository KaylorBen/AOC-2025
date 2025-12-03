package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"

main :: proc() {
  data, ok := os.read_entire_file("input", context.allocator)
  it := string(data)
  joltage := 0
  for line in strings.split_lines_iterator(&it) {
    max := 0
    max2 := 0
    for i in 0..<len(line) {
      value: int = (int)(line[i] - '0')
      if (i != (len(line) - 1) && value > max) {
        max = value
        max2 = 0
      } else if (value > max2) {
        max2 = value
      }
    }
    joltage += max * 10 + max2
  }
  fmt.println(joltage)
}
