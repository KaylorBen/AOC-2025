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
	answer := 0
	OUTER:
	for i := 0; i < len(lines); i++ {
		bounds := strings.Split(string(lines[i]), "-")
		if len(bounds) < 2 {
			continue
		}
		lower, err := strconv.Atoi(bounds[0])
		upper, err := strconv.Atoi(bounds[1])
		_ = err
		if len(ranges) == 0 {
			ranges = append(ranges, IngredientRange{lower, upper})
			answer += upper - lower + 1
			continue
		}
		for k, r := range ranges {
			_ = k
			if upper < r.lower || lower > r.upper {
				continue
			}
			if lower >= r.lower && upper <= r.upper {
				continue OUTER
			}
			if lower < r.lower && upper > r.upper {
				lines = append(lines, fmt.Sprintf("%d-%d", lower, r.lower - 1))
				lines = append(lines, fmt.Sprintf("%d-%d", r.upper + 1, upper))
				continue OUTER
			}
			if lower < r.lower {
				upper = r.lower - 1
			}
			if upper > r.upper {
				lower = r.upper + 1
			}
		}
		ranges = append(ranges, IngredientRange{lower, upper})
		answer += upper - lower + 1
	}
	fmt.Println(answer)
}
