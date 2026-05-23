package main

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"sort"
	"strconv"
	"strings"
	"time"
)

type item struct {
	Name  string
	Count int
}

const chartWidth = 25

func git(args ...string) string {
	cmd := exec.Command("git", args...)
	var out bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = nil
	_ = cmd.Run()
	return strings.TrimSpace(out.String())
}

func totalCommits() int {
	out := git("rev-list", "--count", "HEAD")
	n, err := strconv.Atoi(strings.TrimSpace(out))
	if err != nil {
		return 0
	}
	return n
}

func chart(value, total int, label string) {
	if total == 0 {
		total = 1
	}

	ratio := float64(value) / float64(total)
	size := int(ratio * chartWidth)

	if size < 1 {
		size = 1
	}

	if size > chartWidth {
		size = chartWidth
	}

	bar := strings.Repeat("=", size)
	fmt.Printf("%-20s | %4d | %-*s %5.1f%%\n", label, value, chartWidth, bar, ratio*100)
}

func authors() {
	fmt.Println("Top Contributors")
	total := totalCommits()
	out := git("log", "--all", "--pretty=format:%an")
	lines := strings.Split(out, "\n")
	counts := map[string]int{}

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		counts[line]++
	}

	var items []item
	for k, v := range counts {
		items = append(items, item{k, v})
	}

	sort.Slice(items, func(i, j int) bool {
		return items[i].Count > items[j].Count
	})

	limit := min(10, len(items))
	for i := 0; i < limit; i++ {
		label := fmt.Sprintf("#%d %s", i+1, items[i].Name)
		chart(items[i].Count, total, label)
	}
	fmt.Printf("\nTotal commits: %d\n", total)
}

func timeline() {
	fmt.Println("Commits Over Time")
	total := totalCommits()
	out := git("log", "--date=format:%Y-%m", "--pretty=format:%ad")
	lines := strings.Split(out, "\n")
	counts := map[string]int{}

	for _, line := range lines {
		if line == "" {
			continue
		}
		counts[line]++
	}

	var months []string
	for month := range counts {
		months = append(months, month)
	}

	sort.Strings(months)
	for _, month := range months {
		chart(counts[month], total, month)
	}
}

func days() {
	fmt.Println("Most Active Days")
	total := totalCommits()
	out := git("log", "--date=format:%A", "--pretty=format:%ad")
	lines := strings.Split(out, "\n")
	counts := map[string]int{}

	for _, line := range lines {
		if line == "" {
			continue
		}
		counts[line]++
	}

	var items []item
	for k, v := range counts {
		items = append(items, item{k, v})
	}

	sort.Slice(items, func(i, j int) bool {
		return items[i].Count > items[j].Count
	})

	for _, item := range items {
		chart(item.Count, total, item.Name)
	}
}

func files() {
	fmt.Println("Most Changed Files")
	out := git("log", "--name-only", "--pretty=format:")
	lines := strings.Split(out, "\n")
	counts := map[string]int{}

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		counts[line]++
	}

	var items []item
	for k, v := range counts {
		items = append(items, item{k, v})
	}

	sort.Slice(items, func(i, j int) bool {
		return items[i].Count > items[j].Count
	})

	limit := min(15, len(items))
	for i := 0; i < limit; i++ {
		fmt.Printf("%5d  %s\n", items[i].Count, items[i].Name)
	}
}

func times() {
	fmt.Println("Commit Time Patterns")
	total := totalCommits()
	out := git("log", "--pretty=format:%ad", "--date=format:%H")
	lines := strings.Split(out, "\n")
	counts := map[string]int{}
	lateNight := 0

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}

		counts[line]++
		hour, err := strconv.Atoi(line)

		if err == nil {
			if hour >= 22 || hour < 5 {
				lateNight++
			}
		}
	}

	fmt.Println("-- By Hour --")
	var hours []string
	for h := range counts {
		hours = append(hours, h)
	}

	sort.Strings(hours)
	for _, hour := range hours {
		chart(counts[hour], total, hour+":00")
	}

	fmt.Println()
	fmt.Println("-- Late Night Coding (22:00-04:00) --")

	pct := 0.0
	if total > 0 {
		pct = float64(lateNight) * 100 / float64(total)
	}

	fmt.Printf("late night commits: %d (%.1f%%)\n", lateNight, pct)
}

func churn() {
	fmt.Println("Code Churn (Last 30 days)")
	since := time.Now().AddDate(0, 0, -30).Format("2006-01-02")
	out := git("log", "--since="+since, "--numstat", "--pretty=tformat:")
	lines := strings.Split(out, "\n")

	added := 0
	removed := 0
	for _, line := range lines {
		fields := strings.Fields(line)
		if len(fields) < 2 {
			continue
		}

		a, err1 := strconv.Atoi(fields[0])
		d, err2 := strconv.Atoi(fields[1])

		if err1 != nil || err2 != nil {
			continue
		}

		added += a
		removed += d
	}

	fmt.Printf("Lines added:    +%d\n", added)
	fmt.Printf("Lines removed:  -%d\n", removed)
	fmt.Printf("Total churn:    %d\n", added+removed)
}

func help() {
	fmt.Println("Usage: git scope [flags]")
	fmt.Println()
	fmt.Println("Flags:")
	fmt.Println("  --authors      Top Contributors")
	fmt.Println("  --timeline     Commits over time")
	fmt.Println("  --days         Most active days")
	fmt.Println("  --files        Most changed files")
	fmt.Println("  --times        Commit time patterns")
	fmt.Println("  --churn        Code churn stats")
	fmt.Println("  --all          Run all")
}

func main() {
	if len(os.Args) < 2 {
		help()
		return
	}

	switch os.Args[1] {
	case "--authors":
		authors()
	case "--timeline":
		timeline()
	case "--days":
		days()
	case "--files":
		files()
	case "--times":
		times()
	case "--churn":
		churn()
	case "--all":
		authors()
		fmt.Println()

		timeline()
		fmt.Println()

		days()
		fmt.Println()

		files()
		fmt.Println()

		times()
		fmt.Println()

		churn()
	default:
		help()
	}
}
