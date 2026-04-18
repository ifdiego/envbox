# git-scope-alias

A Git alias that provides a set of repository insights-contributors through simple CLI commands.

#### Getting Started

Download and run the installer in one command:

```bash
curl -fsSL https://raw.githubusercontent.com/ifdiego/git-scope-alias/main/install.sh | bash
```

#### Usage

After installation, you can use the following commands:

```bash
git scope --authors      # Top contributors with rankings
git scope --churn        # Code churn statistics
git scope --days         # Most active days
git scope --files        # Most frequently changed files
git scope --timeline     # Commits over time (monthly)
git scope --times        # Commit time patterns

# You can run all scopes with a single command or uninstall if you prefer
git scope --all          # All scopes
git scope --uninstall    # Remove the alias
```
