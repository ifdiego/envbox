#!/usr/bin/env bash

# the git alias definition
ALIAS_DEFINITION='!f() {
    get_total_commits() {
        git rev-list --count HEAD 2>/dev/null || echo "0"
    }

    chart() {
        local value=$1
        local total=$2
        local label="$3"
        local width=25

        [ "$total" -eq 0 ] && total=1
        local ratio=$(echo "scale=3; $value / $total" | bc 2>/dev/null || echo "0")
        local size=$(echo "$ratio * $width" | bc 2>/dev/null | awk "{printf \"%d\", \$1}")
        [ -z "$size" ] && size=0
        [ "$size" -lt 1 ] && size=1
        [ "$size" -gt "$width" ] && size=$width

        local bar=
        local i=
        for i in $(seq 1 $size); do bar="${bar}="; done
        [ -z "$bar" ] && bar="="
        local percent=$(echo "$ratio * 100" | bc 2>/dev/null | awk "{printf \"%.1f\", \$1}")

        printf "%-20s | %4s | %-*s %5s%%\n" "$label" "$value" "$width" "$bar" "$percent"
    }

    _authors() {
        echo "Top Contributors"

        local total_commits
        total_commits=$(get_total_commits)

        local data
        data=$(git log --all --pretty=format:"%an" | sort | uniq -c | sort -rn | head -10)

        local rank=0
        echo "$data" | while read count name; do
            [ -z "$name" ] && continue
            rank=$((rank + 1))
            local author="#$rank $name"
            chart "$count" "$total_commits" "$author"
        done

        echo ""
        echo "Total commits: $total_commits"
    }

    _timeline() {
        echo "Commits Over Time"

        local total_commits
        total_commits=$(get_total_commits)

        local data
        data=$(git log --date=format:"%Y-%m" --pretty=format:"%ad" | sort | uniq -c | sort -k2)

        echo "$data" | while read count month; do
            [ -z "$month" ] && continue
            chart "$count" "$total_commits" "$month"
        done
    }

    _days() {
        echo "Most Active Days"

        local total_commits
        total_commits=$(get_total_commits)

        local data
        data=$(git log --date=format:"%A" --pretty=format:"%ad" | sort | uniq -c | sort -rn | head -7)

        echo "$data" | while read count day; do
            [ -z "$data" ] && continue
            chart "$count" "$total_commits" "$day"
        done
    }

    _files() {
        echo "Most Changed Files"

        git log --name-only --pretty=format:"" | sort | uniq -c | sort -rn | head -15 | while read count file; do
            [ -n "$file" ] && printf "%5d  %s\n" "$count" "$file"
        done
    }

    _times() {
        echo "Commit Time Patterns"

        local total_commits
        total_commits=$(get_total_commits)

        echo "-- By Hour --"
        git log --pretty=format:"%ad" --date=format:"%H" | sort | uniq -c | sort -rn | while read count hour; do
            [ -n "$hour" ] && chart "$count" "$total_commits" "${hour}:00"
        done

        echo ""
        echo "-- Late Night Coding (22:00-04:00) --"
        local late
        late=$(git log --pretty=format:"%ad" --date=format:"%H" | awk "$1 >= 22 || $1 < 5" | wc -l)

        local pct
        pct=$(echo "scale=1; $late * 100 / $total_commits" | bc)
        echo "late night commits: $late ($pct%)"
    }

    _churn() {
        echo "Code Churn (Last 30 days)"

        local data
        data=$(git log --since="30 days ago" --pretty=tformat:"%h" --numstat | \
            awk "{add+=\$1; del+=\$2} END {print add, del}")

        local added removed
        added=$(echo "$stats" | awk "{print \$1}")
        removed=$(echo "$stats" | awk "{print \$2}")
        [ -z "$added" ] && added=0
        [ -z "$removed" ] && removed=0
        local changes=$((added + removed))

        echo "Lines added:    +$added"
        echo "Lines removed:  -$removed"
        echo "Total churn:    $changes"
    }

    _help() {
        echo "Usage: git scope [flags]"
        echo ""
        echo "Flags:"
        echo "  --authors      Top contributors with rankings"
        echo "  --timeline     Commits over time (monthly)"
        echo "  --days         Most active days"
        echo "  --files        Most changed files"
        echo "  --times        Commit time patterns"
        echo "  --churn        Code churn stats"
        echo "  --all          All scopes"
        echo "  --uninstall    Remove alias"
    }

    if [ $# -eq 0 ]; then
        _help
        return
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            --authors) _authors ;;
            --timeline) _timeline ;;
            --days) _days ;;
            --files) _files ;;
            --times) _times ;;
            --churn) _churn ;;
            --all) _authors; _timeline; _days; _files; _times; _churn ;;
            --uninstall)
                git config --global --unset alias.scope
                echo "Git scope alias removed!"
                return
                ;;
            *) _help ;;
        esac
        shift
    done
};f'

# function to add the alias to git config
install_git_alias() {
    # escape single quotes in the alias definition
    ESCAPED_ALIAS=$(echo "$ALIAS_DEFINITION" | sed "s/'/'\\\\''/g")

    # add the alias to git config
    git config --global alias.scope "$ESCAPED_ALIAS"

    echo "Git scope alias has been installed successfully!"
    echo "You can now use 'git scope' to view statistics of a repo"
}

# run the installation
install_git_alias
