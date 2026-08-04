# Resource safety & memory leaks (ironcode reference)

Load when the change creates anything that must be released: controllers, listeners,
subscriptions, streams, timers, file/socket handles, observers, or long-lived caches.

## The universal rule
**Every acquired resource has an explicit owner and a release that is guaranteed on
every exit path** — ideally written in the same edit that acquires it. Shared
ownership (pools, ref counting, DI containers, RAII) is fine when the owner is
named and the release is guaranteed. If you can create it but cannot point to
where it is released, that is a 🔴 leak. Exceptions that are *decisions, not
accidents*: app-lifetime singletons, framework-owned objects the framework
disposes, and finite streams that complete — name them as such.

## What leaks (check each that applies)
- **Subscriptions / streams.** Every `.listen()` / `subscribe()` call returns a
  subscription that must be `.cancel()`ed (finite streams that complete are the
  stated exception). Realtime channels (e.g. Supabase) must be
  `removeChannel`/`unsubscribe`ed.
- **Listeners / observers.** Every `addListener`/`addEventListener`/`addObserver` needs a
  matching `removeListener` on teardown. Anonymous closures can't be removed — keep a ref.
- **Controllers / disposables — universal.** Anything with a lifecycle must be released
  in its lifecycle-end hook. This is non-negotiable in *every* codebase, not one
  framework. Match the create site to its teardown:
  - Flutter: `AnimationController`/`TextEditingController`/`ScrollController`/`FocusNode`/
    `StreamController` → `dispose()`; GetX controllers/workers (`ever`/`debounce`/`interval`)
    → `onClose()` + `worker.dispose()`; `Get.put` vs `Get.lazyPut(fenix:)`/`permanent`/
    `Get.delete` lifecycle understood (a `permanent` controller never frees — intended?).
  - JS/TS: `AbortController.abort()`, `clearInterval`/`clearTimeout`, `removeEventListener`,
    React effect cleanup `return () => …`, `ResizeObserver.disconnect()`.
  - C#/Java/Kotlin: `IDisposable`/`using`, `AutoCloseable`/try-with-resources,
    `CancellationToken`, coroutine scope cancellation.
  - Go: `defer x.Close()`, cancel `context.Context`. Rust: rely on `Drop`, don't `mem::forget`.
  An object that creates one of these and has no teardown path is a 🔴 leak — reportable
  without running anything.
- **Timers / periodic work.** `Timer`, `Timer.periodic`, intervals, `setInterval` — cancel
  on teardown; a periodic timer also keeps firing network/DB calls = cost leak.
- **Handles.** Files, sockets, DB connections, isolates — close in `finally` so they
  release on the error path too.
- **Async after dispose.** Guard `setState`/state updates with `if (!mounted) return;`
  after an `await`. Cancel in-flight work the user navigated away from.
- **Retain cycles / captured context.** In GC languages the question is
  *reachability from a long-lived root*: a global/singleton holding a closure that
  captures a screen/widget/`BuildContext` pins it for the root's lifetime.
  Unregister the closure on teardown (or use weak refs where idiomatic). In
  ref-counted environments (Swift/ObjC), true cycles need `weak`/`unowned`.
- **Unbounded growth.** Caches/lists/maps with no eviction or cap; accumulating history;
  growing `List` in a `build`/render path. Bound them (LRU, max size, windowing).
- **Image/asset memory.** Decode at display size, not full resolution
  (`cacheWidth`/resize APIs); cap the in-memory image cache; release/recycle
  bitmaps where the platform requires it (e.g. Android `Bitmap.recycle`,
  `ui.Image.dispose`).

## Verification
- Look for the create/dispose pair in the diff. Missing pair on a `StatefulWidget` /
  view-model is reportable without running anything.
- When feasible, compare heap/retained-object snapshots across repeated
  navigate-in/navigate-out cycles (after forcing GC). A monotonic climb of
  *retained objects of the screen's types* indicates a leak; raw memory wobbling
  is normal allocator/GC behavior, not proof either way.

## Finding shape
```
🔴 lib/feature/page.dart:31 — ScrollController created, no dispose(); leaks on every
   page push. Fix: override dispose() and call _scrollController.dispose().
```
