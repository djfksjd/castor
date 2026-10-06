# Security (CASTOR reference)

Load when the change touches outside input, authentication or authorization,
secrets, network calls, storage, or caches of per-user data. Rank findings by
exploitability × blast radius, and show the actual bypass path before reporting
one. Write fixes in the language of the vulnerable code.

The checks below are selected because they change review decisions. They track
the categories of the OWASP Top 10 (2025) without reproducing it.

## Access control (check first; it is the most common serious defect)

Build the matrix the change implies: **principal × operation × resource**.

- Every route, function and query authorizes the caller for *this* object, not
  merely "is logged in". Try the request as user B against user A's id.
- **Row-level security / database policies:** evaluate the effective result,
  not the presence of an expression. Check grants, every applicable policy per
  operation (select, insert, update, delete), views and functions that run
  with elevated rights, and privileged keys or service roles that bypass
  policies. Public-read, membership and role policies are legitimate; a policy
  that mentions the user id is not automatically correct.
- **Authorization across layers:** follow the principal through fetch, cache,
  transformation and response. A shared cache, CDN, memoized server value or
  service account can serve user A's data to user B while the database rules
  are perfect. Check cache keys include tenant and user, and that logout or a
  permission change invalidates them.
- **Mass assignment:** request bodies bound straight onto models let a caller
  set `role`, `owner_id` or `price`. Allowlist writable fields.
- Client-side filtering and hidden UI are not access control.

## Injection and output handling

- Queries receive untrusted *values* only as bound parameters, never by string
  concatenation. Identifiers, operators and sort directions cannot be bound:
  choose them from a fixed allowlist.
- External commands are run with an argument array, not through a shell, and
  arguments that could begin with `-` are guarded against option injection.
- XSS: encode output for its context by default; sanitize only when rich
  user HTML is deliberately rendered.
- Paths and redirect targets derived from input are validated (traversal,
  open redirect).
- Never feed untrusted data to unsafe deserializers or `eval`-style parsers.

## Authentication and sessions

- Tokens: verify signature, expiry, audience and issuer, and pin the accepted
  algorithms. Reject `none` and algorithm confusion.
- Cookie-authenticated state changes need CSRF protection (SameSite plus a
  token or origin check as the framework provides).
- No user enumeration through differing errors or timing; rate-limit login,
  reset and other expensive or guessable endpoints.
- Passwords use a slow salted hash (argon2, scrypt, bcrypt). Security tokens
  come from a cryptographic RNG.

## Outbound requests and callbacks

- **SSRF:** a URL the server fetches on user input is allowlisted by
  destination, checked after DNS resolution and after every redirect, and
  cannot reach internal ranges or metadata endpoints.
- **Webhooks:** verify the signature over the raw body, reject stale
  timestamps, and dedupe by event id so a replay is harmless.

## Secrets and configuration

- Scan the diff for credentials (keys, tokens, passwords, connection strings,
  private-key headers). A match is a candidate: confirm it is a live credential
  rather than a public key, placeholder or test fixture. Use a dedicated
  scanner for history, and never re-print a secret you find.
- A confirmed exposed credential is 🔴. Recommend rotation; do not rotate or
  revoke anything yourself without authorization.
- Anything shipped to a client (web bundle, mobile binary, firmware image) is
  public. Privileged keys stay server-side.
- Debug modes, default credentials, verbose errors, permissive CORS with
  credentials, and public storage buckets are checked when configuration
  changes.
- Secrets, tokens and personal data never go to logs, analytics or error
  reports.

## Dependencies

When dependencies change, run the ecosystem's audit (`npm audit`, `pip-audit`,
`cargo audit`, `govulncheck`, `osv-scanner`). An advisory is a candidate:
confirm the affected version range and that the vulnerable code path is
reachable before assigning severity. Confirm new packages exist under the
exact name and publisher intended.

## Applications that call a language model

When the change passes untrusted text to a model or acts on model output:

- Retrieved documents, web pages, tool results and user uploads can carry
  instructions. They must not be able to trigger privileged tools or data
  access the end user does not have.
- Tools run with the *user's* authority, least privilege, and confirmation for
  destructive or outward-facing actions.
- Model output is untrusted input to whatever consumes it (HTML, SQL, shell,
  file paths).
- Secrets and other users' data stay out of prompts and logs.

## Client and device specifics

- Sensitive data lives in the platform's secure storage, not plain
  preferences.
- Deep-link and intent parameters are validated like any other input.
- Device-side concerns (debug ports, read-out protection, secure boot, signed
  updates) are in `domains/firmware.md`.

## Finding shape

```
F1 🔴 api/invoices.ts:27 — any authenticated user requests /invoices/:id with
   another account's id → handler loads by id with no owner check → reads
   that account's invoice (amounts, address).
   Evidence: static trace; query at :27 filters on id only, and the route's
   middleware (router.ts:12) checks authentication only.
   Fix: add `and account_id = $session.accountId` and return 404 on no row.
```
