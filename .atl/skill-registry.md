# Skill Registry

**Delegator use only.** Any agent that launches sub-agents reads this registry to resolve compact rules, then injects them directly into sub-agent prompts. Sub-agents do NOT read this registry or individual SKILL.md files.

See `_shared/skill-resolver.md` for the full resolution protocol.

## User Skills

| Trigger | Skill | Path |
|---------|-------|------|
| graphify query | graphify | /home/alex_/.config/opencode/skills/graphify/SKILL.md |
| work-unit-commits | work-unit-commits | /home/alex_/.config/opencode/skills/work-unit-commits/SKILL.md |
| comment-writer | comment-writer | /home/alex_/.config/opencode/skills/comment-writer/SKILL.md |
| cognitive-doc-design | cognitive-doc-design | /home/alex_/.config/opencode/skills/cognitive-doc-design/SKILL.md |
| chained-pr | gentle-ai-chained-pr | /home/alex_/.config/opencode/skills/chained-pr/SKILL.md |
| skill-registry | skill-registry | /home/alex_/.config/opencode/skills/skill-registry/SKILL.md |
| crafting-rules | crafting-rules | /home/alex_/.config/opencode/skills/crafting-rules/SKILL.md |
| branch-pr | branch-pr | /home/alex_/.config/opencode/skills/branch-pr/SKILL.md |
| judgment-day | judgment-day | /home/alex_/.config/opencode/skills/judgment-day/SKILL.md |
| go-testing | go-testing | /home/alex_/.config/opencode/skills/go-testing/SKILL.md |
| issue-creation | issue-creation | /home/alex_/.config/opencode/skills/issue-creation/SKILL.md |
| frontend-design | frontend-design | /home/alex_/.agents/skills/frontend-design/SKILL.md |
| mcp-builder | mcp-builder | /home/alex_/.agents/skills/mcp-builder/SKILL.md |
| find-skills | find-skills | /home/alex_/.agents/skills/find-skills/SKILL.md |
| pencil-design | pencil-design | /home/alex_/.agents/skills/pencil-design/SKILL.md |
| context7 | context7 | /home/alex_/.agents/skills/context7/SKILL.md |
| feature-sliced-design | feature-sliced-design | /home/alex_/.agents/skills/feature-sliced-design/SKILL.md |
| minimax-image-understanding | minimax-image-understanding | /home/alex_/.agents/skills/minimax-image-understanding/SKILL.md |
| opencode | opencode | /home/alex_/.agents/skills/opencode/SKILL.md |
| skill-creator | skill-creator | /home/alex_/.agents/skills/skill-creator/SKILL.md |
| depwire | depwire | /home/alex_/develop/playvion/.agents/skills/depwire/SKILL.md |

## Compact Rules

Pre-digested rules per skill. Delegators copy matching blocks into sub-agent prompts as `## Project Standards (auto-resolved)`.

### graphify
- Any input (code, docs, papers, images, videos) to knowledge graph
- When user asks any question about a codebase, documents, or project content
- If graphify-out/ exists, treat the question as a /graphify query

### work-unit-commits
- Structure commits as deliverable work units instead of file-type batches
- Tests and docs kept beside the code they verify
- Trigger: when implementing a change, preparing commits, splitting PRs, or planning chained or stacked PRs

### comment-writer
- Write warm, direct, human comments for PRs, issues, reviews, chats, and async collaboration
- Trigger: when drafting or posting feedback, review comments, maintainer replies, Slack messages, or GitHub comments

### cognitive-doc-design
- Design documentation that reduces reader cognitive load through progressive disclosure, chunking, signposting, tables, checklists, and recognition over recall
- Trigger: when writing guides, READMEs, RFCs, onboarding docs, architecture docs, or review-facing documentation

### gentle-ai-chained-pr
- Split large changes into chained or stacked pull requests that protect reviewer focus and stay within Gentle AI's 400-line cognitive review budget
- Trigger: when a PR would exceed 400 changed lines, when planning chained PRs, stacked PRs, or reviewable slices

### crafting-rules
- Use when creating or modifying OpenCode rules (.md/.mdc files) that customize agent behavior
- Trigger: when user wants to create a rule, codify repeated instructions, persist guidance across sessions, or scope rules to specific files, prompts, environments, or workflows

### branch-pr
- PR creation workflow for Agent Teams Lite following the issue-first enforcement system
- Trigger: When creating a pull request, opening a PR, or preparing changes for review

### judgment-day
- Parallel adversarial review protocol that launches two independent blind judge sub-agents simultaneously
- Trigger: When user says "judgment day", "review adversarial", "dual review", "doble review", "juzgar"

### go-testing
- Go testing patterns for Gentleman.Dots, including Bubbletea TUI testing
- Trigger: When writing Go tests, using teatest, or adding test coverage

### issue-creation
- Issue creation workflow for Agent Teams Lite following the issue-first enforcement system
- Trigger: When creating a GitHub issue, reporting a bug, or requesting a feature

### frontend-design
- Create distinctive, production-grade frontend interfaces with high design quality
- Trigger: when user asks to build web components, pages, artifacts, posters, or applications

### mcp-builder
- Guide for creating high-quality MCP (Model Context Protocol) servers that enable LLMs to interact with external services
- Trigger: when building MCP servers to integrate external APIs or services

### find-skills
- Helps users discover and install agent skills
- Trigger: when user asks questions like "how do I do X", "find a skill for X", "is there a skill that can..."

### pencil-design
- Design UIs in Pencil (.pen files) and generate production code from them
- Trigger: when working with .pen files, designing screens or components in Pencil, or generating code from Pencil designs

### context7
- Retrieve up-to-date documentation for software libraries, frameworks, and components via the Context7 API
- Trigger: when looking up documentation for any programming library or framework

### feature-sliced-design
- Apply Feature-Sliced Design (FSD) v2.1 architectural methodology to frontend projects
- Trigger: when organizing code structure, decomposing features, creating new components or features, refactoring existing codebases

### minimax-image-understanding
- Analyze images using AI with the understand_image tool

### opencode
- Expert guide for working with opencode.ai - TUI commands, CLI operations, custom commands, agents, tools, skills system, and AGENTS.md configuration

### skill-creator
- Create new skills, modify and improve existing skills, and measure skill performance
- Trigger: when users want to create a skill from scratch, edit, or optimize an existing skill

### depwire
- Architecture analysis, refactor safety, dead code detection, security scanning, and dependency-aware code changes
- Trigger: when user mentions depwire, wants to analyze code structure, find unused code, plan refactoring, check impact before changes, understand dependencies, audit security

## Project Conventions

No convention files found in project root.