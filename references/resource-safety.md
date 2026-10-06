# Resource safety and lifetimes (CASTOR reference)

Load when the change acquires something that must be released, or creates
something long-lived: subscriptions, listeners, streams, timers, controllers,
file and socket handles, connections, tasks, caches.

## Three different questions

Keep them apart; mixing them is the main source of false leak reports.

1. **Ownership.** Who is responsible for releasing an external resource
   (handle, connection, subscription, hardware peripheral)?
2. **Cancellation.** Is pending work stopped when nobody wants its result?
3. **Reachability.** In a garbage-collected runtime, is an object kept alive
   by a reference from something that outlives it?

## When it is a finding

A create without a visible release next to it is a **candidate**. Before
reporting, look for the release elsewhere (a base class, a framework lifecycle,
a container, a scope, an abort signal) and establish what actually survives:

- the **root** that keeps it alive or the external resource that stays open,
- the **trigger** that repeats it (every navigation, every request, every
  reconnect), and
- the **consequence** (memory growth, duplicate callbacks, exhausted handles,
  work and network calls continuing for nobody).

Not leaks: objects owned by an app-lifetime singleton on purpose, objects the
framework disposes, streams and requests that complete on their own, a listener
on an object that dies with its subscriber.

## Where to look

- **Subscriptions and streams.** A subscription to a long-lived source is
  cancelled at the subscriber's end of life. Realtime channels are removed.
- **Listeners and observers.** Removed on teardown by the mechanism the API
  provides: a kept callback reference, an abort signal, a returned
  unsubscribe function. A `once` listener removes itself only when the event
  fires; if it may never fire, it still needs teardown.
- **Timers and periodic work.** Cancelled on teardown. A leaked periodic timer
  is also a cost leak: it keeps issuing network and database calls.
- **Handles and connections.** Closed on every exit path, including the error
  path: `finally`, `defer`, `using`, try-with-resources, context managers,
  RAII. Pooled connections are returned.
- **Pending work.** Requests and tasks the user navigated away from are
  cancelled or their results ignored; state is not updated on a destroyed
  owner.
- **Captured context.** A global, singleton or cache holding a closure that
  captures a screen, component or request pins it for the holder's lifetime.
  In reference-counted runtimes, true cycles need a weak reference.
- **Unbounded growth.** Caches, maps, lists and histories with no cap or
  eviction, keyed by something users can multiply.
- **Large assets.** Images decoded far above display size, unbounded image
  caches, native buffers the platform expects you to release.

## Examples by stack (examples, not universal contracts)

Use the release the actual API documents.

- **Flutter/Dart:** `dispose()` for animation, text, scroll and focus objects;
  `close()` for a `StreamController`; `cancel()` for a `StreamSubscription`
  and `Timer`.
- **JS/TS:** effect cleanup functions, `removeEventListener` or an
  `AbortSignal`, `clearInterval`/`clearTimeout`, observer `disconnect()`.
  Aborting matters for work still pending, not for work that completed.
- **C#/Java/Kotlin:** `using`/`IDisposable`, try-with-resources, cancellation
  tokens, coroutine scope cancellation.
- **Go:** `defer x.Close()`, context cancellation, goroutines that can always
  exit. **Rust:** `Drop`; watch for `mem::forget` and reference cycles.
- **C/C++ and firmware:** every allocation and peripheral claim has one owner;
  see `domains/firmware.md`.

## Verification

- Static: trace from the create site to the release and to the root that would
  hold it. A complete trace is sufficient evidence for a finding.
- Dynamic, when feasible: repeat the acquire/release cycle (navigate in and
  out, connect and disconnect) and compare retained instances of the relevant
  types after forcing collection. A steady climb in *retained instances* is a
  leak; total memory moving up and down is not evidence either way.

## Finding shape

```
F1 🔴 src/chat/ChatPanel.tsx:22 — every open of the panel subscribes to the
   app-wide socket bus and never unsubscribes → the bus keeps each panel's
   closure alive and invokes all of them per message → memory grows per open
   and each message is handled N times.
   Evidence: static trace; `bus.on` at :22, effect returns no cleanup, bus is
   the module singleton from socket.ts:5.
   Fix: return `() => bus.off('message', handler)` from the effect.
```
