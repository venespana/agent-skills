#!/bin/bash
# depwire-refactor-safe.sh
# Safe refactoring workflow using depwire
# Usage: ./depwire-refactor-safe.sh <symbol> <old-path> [new-path]

set -e

SYMBOL="${1:-}"
OLD_PATH="${2:-}"
NEW_PATH="${3:-}"

if [ -z "$SYMBOL" ] || [ -z "$OLD_PATH" ]; then
  echo "Usage: depwire-refactor-safe.sh <symbol> <old-path> [new-path]"
  echo ""
  echo "Examples:"
  echo "  # Rename a service"
  echo "  ./depwire-refactor-safe.sh UserService src/services/user.service.ts src/services/user-manager.ts"
  echo ""
  echo "  # Delete unused code"
  echo "  ./depwire-refactor-safe.sh OldUtil src/utils/old-util.ts"
  echo ""
  echo "  # Move to new location"
  echo "  ./depwire-refactor-safe.sh AuthService src/auth/service.ts lib/auth/service.ts"
  exit 1
fi

OPERATION="rename"
if [ -z "$NEW_PATH" ]; then
  OPERATION="delete"
fi

echo "=== Depwire Safe Refactoring Workflow ==="
echo "Symbol: $SYMBOL"
echo "Old path: $OLD_PATH"
echo "New path: ${NEW_PATH:-<deletion>}"
echo "Operation: $OPERATION"
echo ""

# Step 1: Impact analysis
echo "Step 1: Analyzing impact..."
echo "Command: impact_analysis(symbol=\"$SYMBOL\")"
echo ""
echo "Review these before proceeding:"
echo "  - Direct dependents count"
echo "  - Transitive dependents count"
echo "  - Cross-language dependencies"
echo "  - Test files affected"
echo ""

# Step 2: If renaming/moving, simulate
if [ "$OPERATION" = "rename" ]; then
  echo "Step 2: Simulating change..."
  echo "Command: simulate_change(operation=\"rename\", target=\"$OLD_PATH\", destination=\"$NEW_PATH\")"
  echo ""
  echo "Review these before proceeding:"
  echo "  - health_delta: negative = risk, positive = improvement"
  echo "  - broken_imports: files that will break"
  echo "  - affected_nodes: all downstream consumers"
  echo ""
fi

echo "Step 3: Decision point"
echo "====================="
echo ""
echo "Based on impact and simulation results:"
echo ""
echo "  If impact shows >10 affected files:"
echo "    → Break into smaller PRs"
echo "    → Use chained PRs skill"
echo ""
echo "  If health_delta < -10:"
echo "    → Consider alternative approach"
echo "    → Get user approval"
echo ""
echo "  If broken_imports > 5:"
echo "    → Batch update imports in separate PR"
echo ""
echo "  If cross-language dependencies exist:"
echo "    → Check other language codebases"
echo "    → Coordinate with team"
echo ""

# Step 4: Pre-commit verification
echo "Step 4: Pre-commit safety check"
echo "Command: verify_change(file_path=\"$OLD_PATH\")"
echo ""
echo "Must pass before commit:"
echo "  - broken_imports: 0"
echo "  - circular_dependencies: 0"
echo "  - health_score_delta: not negative"
echo ""

echo "=== Workflow Summary ==="
echo ""
echo "1. impact_analysis → understand blast radius"
echo "2. simulate_change → preview exact breakage"
echo "3. Present to user → get approval if large"
echo "4. verify_change → pre-commit gate"
echo "5. Apply changes → run quality gates"
echo "6. Commit → use commit message with depwire summary"
echo ""
echo "For automated execution, use MCP tools in agent workflow."