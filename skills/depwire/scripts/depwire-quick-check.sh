#!/bin/bash
# depwire-quick-check.sh
# Fast dependency check before making changes
# Usage: ./quick-check.sh <target-symbol> [operation]

set -e

TARGET="${1:-}"
OPERATION="${2:-impact}"

if [ -z "$TARGET" ]; then
  echo "Usage: depwire-quick-check.sh <target-symbol> [operation]"
  echo "  operation: impact (default) | simulate | verify"
  echo ""
  echo "Examples:"
  echo "  depwire-quick-check.sh UserService"
  echo "  depwire-quick-check.sh src/services/user.service.ts simulate"
  exit 1
fi

echo "=== Depwire Quick Check ==="
echo "Target: $TARGET"
echo "Operation: $OPERATION"
echo ""

case "$OPERATION" in
  impact)
    echo "Running impact analysis..."
    # This would be called via MCP tool in actual agent workflow
    # Script serves as documentation and quick reference
    echo ""
    echo "For agent execution, use:"
    echo "  impact_analysis(symbol=\"$TARGET\")"
    echo ""
    echo "Review:"
    echo "  - Direct dependents (what breaks immediately)"
    echo "  - Transitive dependents (chain reaction)"
    echo "  - Affected files (count)"
    echo "  - Cross-language edges (REST API, subprocess)"
    ;;
  simulate)
    echo "Running change simulation..."
    echo ""
    echo "For agent execution, use:"
    echo "  simulate_change(operation=\"rename|delete|move|split|merge\", target=\"$TARGET\", destination=\"...\")"
    echo ""
    echo "Review:"
    echo "  - health_delta: negative = risk, positive = improvement"
    echo "  - broken_imports: files that will break"
    echo "  - affected_nodes: all downstream consumers"
    ;;
  verify)
    echo "Running pre-commit safety check..."
    echo ""
    echo "For agent execution, use:"
    echo "  verify_change(file_path=\"$TARGET\")"
    echo ""
    echo "Review:"
    echo "  - broken_imports: must be empty"
    echo "  - circular_dependencies: must be empty"
    echo "  - health_score_delta: must not be negative"
    ;;
  *)
    echo "Unknown operation: $OPERATION"
    exit 1
    ;;
esac

echo ""
echo "=== Quick Decision Guide ==="
echo ""
echo "impact > 5 affected files? → Get user approval before proceeding"
echo "impact includes cross-language? → Check other language codebases"
echo "simulate health_delta < -5? → Consider alternative approach"
echo "verify broken_imports > 0? → Fix imports before commit"
echo ""
echo "For full workflow, use depwire-refactor-safe.sh for refactoring tasks"