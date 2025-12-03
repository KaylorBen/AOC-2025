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
    size := 0
    digits: [12]int
    for i in 0..<len(line) {
      value: int = (int)(line[i] - '0')
      for k in 0..<12 {
        if (i < ((len(line) - (11 - k))) && value > digits[k]) {
          digits[k] = value
          for l := k + 1; l < 12; l += 1 {
            digits[l] = 0
          }
          break
        }
      }
    }
    // sadly couldn't find a simple way to do this w/t odin
    // all math exponent functions expect float, and thats annoying
    joltage += (digits[0]  * 100000000000)
    joltage += (digits[1]  * 10000000000)
    joltage += (digits[2]  * 1000000000)
    joltage += (digits[3]  * 100000000)
    joltage += (digits[4]  * 10000000)
    joltage += (digits[5]  * 1000000)
    joltage += (digits[6]  * 100000)
    joltage += (digits[7]  * 10000)
    joltage += (digits[8]  * 1000)
    joltage += (digits[9]  * 100)
    joltage += (digits[10] * 10)
    joltage += (digits[11])
  }
  fmt.println(joltage)
}
