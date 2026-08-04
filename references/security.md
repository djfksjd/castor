# Security (ironcode reference)

Load when the change touches user input, auth/authz, network, storage, secrets,
queries, or anything reachable from outside the app. Prioritize findings by
**severity × exploitability × blast radius**. Provide fixes in the *same language*
as the vulnerable code.

## First pass (always)
- **Secrets scan.** Grep the *diff* for `api[_-]?key`, `secret`, `password`,
  `token`, `private_key`, connection strings, `-----BEGIN`. For history, use a
  dedicated scanner (gitleaks/trufflehog) rather than grepping `git log -p` —
  faster, fewer false positives, and don't re-print any secret you find. A
  hardcoded or committed secret is 🔴 **and** must be rotated — flagging it is
  not enough.
- **Dependency audit** when deps changed: `npm audit` / `pip-audit` / `cargo audit` /
  `govulncheck` / `osv-scanner` (covers pub.dev and most ecosystems). Report CVE +
  fix version. (`flutter pub outdated` shows staleness, not vulnerabilities.)

## OWASP Top 10 (2021) — what to check
- **A01 Broken Access Control.** Every endpoint/route/query authorizes the *caller*,
  not just authenticates. Object-level checks (can THIS user touch THIS row?). For
  Supabase/Postgres: **RLS enabled on every client-reachable table** with policies
  that actually scope by `auth.uid()`; client-side filtering is not access control.
  CORS not `*` for credentialed requests.
- **A02 Cryptographic Failures.** TLS everywhere; no MD5/SHA1 for passwords (use
  bcrypt/argon2/scrypt); secure RNG (not `Math.random`/`Random()` for tokens);
  no secrets in logs.
- **A03 Injection.** Parameterized queries / prepared statements / query builders —
  never string-concatenate user input into SQL, shell, or `eval`. For XSS: encode
  output for its context (HTML/attribute/JS/URL) by default; HTML-sanitize only
  when you deliberately render user-supplied rich HTML. Validate redirect targets
  and file paths (path traversal `../`).
- **A04 Insecure Design.** Rate-limit auth and expensive endpoints. No security-by-obscurity.
- **A05 Misconfiguration.** Debug off in prod; default creds removed; verbose errors
  not leaked to clients; storage buckets not public unless intended.
- **A06 Vulnerable & Outdated Components.** The dependency audit above, plus:
  pin versions (lockfile committed), remove unused deps, track EOL runtimes.
- **A07 Auth Failures.** Strong session/JWT validation (verify signature, exp, aud);
  rotate/expire tokens; no user enumeration via different error messages.
- **A08 Integrity.** Verify webhook signatures; never feed untrusted data to
  native/unsafe deserializers (pickle, Java serialization, `eval`-style parsers) —
  parse with a schema-validated format (JSON + schema validation) instead.
- **A09 Logging.** Log security events; never log secrets/PII/tokens.
- **A10 SSRF.** Validate/allowlist any URL the server fetches on user input.

## Client-app specifics (mobile/Flutter)
- No secrets baked into the binary — anything shipped to the client is public.
  Service-role keys stay server-side (edge functions), only the anon/publishable key ships.
- Validate/escape deep-link and intent parameters.
- Sensitive data in secure storage (Keychain/Keystore), not plain prefs.
- Authorization decisions belong on the server, not in the UI.

## Reporting a security finding
```
🔴 lib/x.dart:88 — User input concatenated into a Supabase filter (injection).
   Exploitability: high (any client). Blast radius: full table read.
   Fix: use .eq('col', value) / parameterized filter instead of string interpolation.
```
