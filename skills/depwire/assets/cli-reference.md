# Depwire CLI Quick Reference

```bash
# === VISUALIZATION ===

# Interactive arc diagram (opens in browser)
depwire viz

# Visualize with highlighting
depwire viz --highlight=UserService

# Limit to top N connected files
depwire viz --max-files=50


# === WHAT-IF SIMULATION ===

# Simulate renaming a symbol
depwire whatif --target=UserService --operation=rename --new-name=UserManager

# Simulate deleting
depwire whatif --target=OldUtil --operation=delete

# Simulate moving
depwire whatif --target=AuthService --operation=move --destination=lib/auth/

# Simulate splitting
depwire whatif --target=LargeService --operation=split --symbols=PartA,PartB

# Simulate merging
depwire whatif --target=SmallService1 --operation=merge --merge-with=SmallService2


# === HEALTH & ARCHITECTURE ===

# Get health score (0-100)
depwire health

# Get health score with detailed output
depwire health --json

# Architecture summary
depwire health --brief


# === DEAD CODE ===

# Find high-confidence dead code
depwire dead-code --min-confidence=high

# Find medium and high
depwire dead-code --min-confidence=medium

# Find all (includes low)
depwire dead-code --min-confidence=low

# JSON output for automation
depwire dead-code --json


# === SECURITY ===

# Full security scan
depwire security

# Fail pipeline on high/critical
depwire security --fail-on=high

# Fail on critical only
depwire security --fail-on=critical

# Target specific path
depwire security --target=src/api/

# JSON output
depwire security --json


# === DOCUMENTATION ===

# Generate all 13 docs
depwire docs

# Generate specific doc
depwire docs --type=architecture

# Types: architecture, conventions, dependencies, onboarding, files, api_surface, errors, tests, history, current, status, health, dead_code

# Output directory
depwire docs --output=./.depwire/docs


# === TEMPORAL ANALYSIS ===

# Show architecture evolution (last 10 commits)
depwire temporal

# Weekly sampling
depwire temporal --strategy=weekly

# Monthly sampling
depwire temporal --strategy=monthly

# Specific number of commits
depwire temporal --commits=20


# === UTILITY ===

# Parse and export dependency graph as JSON
depwire parse

# Connect to different repo
depwire connect /path/to/repo

# Show version
depwire --version

# Show help
depwire --help


# === COMMON WORKFLOWS ===

# Pre-commit safety check
depwire whatif --target=src/changing/file.ts --operation=rename --new-name=src/changed/file.ts
depwire health

# Before big refactor
depwire health --json > baseline-health.json
depwire whatif --target=BigComponent --operation=split --symbols=Part1,Part2
# Review results, get approval, then implement

# Security audit
depwire security --fail-on=critical
# Fix critical findings
depwire security --fail-on=high
# Fix high findings

# Dead code cleanup
depwire dead-code --min-confidence=high
# Verify with get_dependents
# Delete confirmed dead code
depwire health --json > post-cleanup-health.json

# Onboarding
depwire health --brief
depwire docs --output=./onboarding-docs
# Read generated docs
```
