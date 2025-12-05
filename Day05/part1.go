package main

import (
	"fmt"
	"os"
	"strings"
	"strconv"
)

type IngredientRange struct {
	lower int
	upper int
}

var ranges []IngredientRange

func main() {
	body, err := os.ReadFile("input")
	_ = err
	lines := strings.Split(string(body), "\n")
	range_line_end := 0
	for i, line := range lines {
		bounds := strings.Split(string(line), "-")
		if len(bounds) < 2 {
			range_line_end = i
			break
		}
		lower, err := strconv.Atoi(bounds[0])
		upper, err := strconv.Atoi(bounds[1])
		_ = err
		ranges = append(ranges, IngredientRange{lower, upper})
	}
	answer := 0
	for i := range_line_end + 1; i < len(lines); i++ {
		value, err := strconv.Atoi(lines[i])
		if err != nil {
			break
		}
		for k, r := range ranges {
			_ = k
			if (value <= r.upper && value >= r.lower) {
				answer++
				break
			}
		}
	}
	fmt.Println(answer)
}
