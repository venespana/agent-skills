# Security Scan Guide

Interpreting depwire's security scan findings and graph-aware severity.

## Overview

`security_scan` checks for vulnerabilities across 11 classes:

- `dependency-cve`: Vulnerable third-party dependencies
- `shell-injection`: Command injection via user input
- `code-injection`: Code injection attacks
- `secrets`: Hardcoded credentials, API keys, tokens
- `path-traversal`: Directory traversal vulnerabilities
- `auth`: Authentication/authorization bypass
- `input-validation`: Missing or insufficient input validation
- `information-disclosure`: Exposing sensitive data
- `cryptography`: Weak or improper crypto usage
- `supply-chain`: Supply chain risks
- `frontend-xss`: Cross-site scripting in frontend code
- `architecture`: Architecture-level security risks

## Graph-Aware Severity

Depwire elevates severity based on reachability from attack surfaces:

| Severity     | Condition                                | Example                          |
| ------------ | ---------------------------------------- | -------------------------------- |
| **Critical** | Reachable from MCP tools or HTTP routes  | Shell injection in API endpoint  |
| **High**     | Reachable from internal services         | SQL injection in service method  |
| **Medium**   | Not directly reachable but vulnerable    | Vulnerable dependency in utility |
| **Low**      | Theoretical vulnerability, no clear path | Weak crypto in isolated module   |

**Why this matters**: A medium vulnerability reachable from an HTTP route becomes Critical because remote attackers can exploit it.

## Vulnerability Classes Explained

### Dependency CVEs

**What it finds**: Known vulnerabilities in npm/pip/go packages.

**How to fix**:

```bash
# Update vulnerable package
npm audit fix
# Or update specific package
npm update vulnerable-package@latest
```

**When critical**: When the vulnerable function is called from an HTTP handler.

---

### Shell Injection

**What it finds**: User input passed to shell commands without sanitization.

**Vulnerable pattern**:

```typescript
// ❌ BAD: User input in shell command
const command = `ls ${userInput}`;
exec(command);

// ❌ BAD: Shell metacharacters not escaped
exec(`ls ${directory}`);
```

**Safe pattern**:

```typescript
// ✅ GOOD: No shell interpretation
execFile('ls', [userInput]);

// ✅ GOOD: Strict allowlist
const allowed = ['home', 'documents', 'downloads'];
if (!allowed.includes(userInput)) throw new Error('Invalid');
execFile('ls', [userInput]);
```

**When critical**: When the user input comes from HTTP request parameters or headers.

---

### Hardcoded Secrets

**What it finds**: API keys, tokens, passwords, private keys in source code.

**Vulnerable pattern**:

```typescript
// ❌ BAD: Secret in code
const apiKey = 'sk-1234567890abcdef';
```

**Safe pattern**:

```typescript
// ✅ GOOD: Environment variable
const apiKey = process.env.API_KEY;

// ✅ GOOD: Secrets manager
const apiKey = await secretsManager.get('api-key');
```

**When critical**: When the secret grants access to production systems or sensitive data.

---

### Path Traversal

**What it finds**: User input used in file paths without sanitization.

**Vulnerable pattern**:

```typescript
// ❌ BAD: User input in file path
const file = path.join(baseDir, userInput);
readFile(file);
```

**Safe pattern**:

```typescript
// ✅ GOOD: Normalize and validate
const normalized = path.normalize(userInput);
const fullPath = path.join(baseDir, normalized);
if (!fullPath.startsWith(baseDir)) throw new Error('Invalid path');
readFile(fullPath);
```

**When critical**: When accessible via HTTP endpoints that can read arbitrary files.

---

### Auth Bypass

**What it finds**: Missing authentication checks, improper authorization logic.

**Vulnerable pattern**:

```typescript
// ❌ BAD: No auth check
app.get('/api/admin', (req, res) => {
  // Missing authentication
  res.json(admins);
});
```

**Safe pattern**:

```typescript
// ✅ GOOD: Auth middleware
app.get('/api/admin', authMiddleware, (req, res) => {
  if (!req.user.isAdmin) return res.status(403).end();
  res.json(admins);
});
```

---

### Input Validation

**What it finds**: Missing or insufficient validation of user input.

**Vulnerable pattern**:

```typescript
// ❌ BAD: No validation
const userId = req.body.userId;
db.query(`SELECT * FROM users WHERE id = ${userId}`);
```

**Safe pattern**:

```typescript
// ✅ GOOD: Validate with schema
import { z } from 'zod';
const schema = z.object({ userId: z.string().uuid() });
const { userId } = schema.parse(req.body);
db.query('SELECT * FROM users WHERE id = $1', [userId]);
```

---

### Frontend XSS

**What it finds**: User input rendered without sanitization.

**Vulnerable pattern**:

```typescript
// ❌ BAD: Raw HTML insertion
element.innerHTML = userInput;
```

**Safe pattern**:

```typescript
// ✅ GOOD: Text content or sanitized
element.textContent = userInput;

// ✅ GOOD: Framework auto-escaping
return <div>{userInput}</div>;
```

**When critical**: When the input comes from URL parameters, storage, or external APIs.

---

## Security Scan Workflow

```
1. Run security_scan (full scan or targeted)
2. For each finding sorted by severity:

   CRITICAL:
   a. impact_analysis(symbol)
   b. Identify attack vector
   c. Fix immediately (same session)
   d. verify_change before commit

   HIGH:
   a. Understand exploitability
   b. Fix within current sprint
   c. Document in commit message

   MEDIUM:
   a. Evaluate risk
   b. Schedule for next sprint
   c. Add to tech debt backlog

   LOW:
   a. Document for future cleanup
   b. Add to backlog
```

## Security Scan Integration

### CI Integration

```bash
# Fail pipeline on critical/high findings
depwire security --fail-on=high

# Or in CI script
if depwire security --json | jq '.summary.critical + .summary.high > 0'; then
  echo "Security findings block deployment"
  exit 1
fi
```

### Pre-PR Check

Run `security_scan` as part of pre-PR quality gates:

```
1. verify_change(...) → 0 broken imports
2. get_health_score → no regression
3. security_scan → 0 critical/high findings
4. build → pass
5. lint → pass
6. test → pass
```

## Attack Scenario Examples

### Shell Injection → Remote Code Execution

```
1. User finds endpoint: GET /logs?file=app.log
2. security_scan finds: path traversal in log reader
3. impact_analysis shows: reachable from HTTP route
4. Attacker crafts: GET /logs?file=../../etc/passwd
5. Severity: Critical (remote exploit possible)
```

### Dependency CVE → Data Exfiltration

```
1. security_scan finds: vulnerable jsonwebtoken version
2. impact_analysis shows: used in auth middleware
3. Attacker exploits: CVE allows token forgery
4. Severity: Critical (auth bypass)
```

### Hardcoded Secret → Production Access

```
1. security_scan finds: AWS_KEY in config.ts
2. impact_analysis shows: used in AWS SDK initialization
3. Attacker uses: key to access production S3 buckets
4. Severity: Critical (production compromise)
```

## False Positives

Dead code detection can have false positives. Security scan may too:

- Dynamic imports (runtime loading not detected)
- Reflection usage (meta-programming)
- Framework magic (dependency injection containers)
- Test-only code (not in production)

Always verify with `get_dependents` and `get_file_context` before concluding a finding is real.
