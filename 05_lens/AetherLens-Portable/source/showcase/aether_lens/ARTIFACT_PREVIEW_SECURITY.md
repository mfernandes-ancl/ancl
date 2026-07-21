# Aether Lens HTML/SVG Artifact Preview Security Contract

Updated: 2026-07-16

## Purpose

Lens may render a complete `html`, `htm`, or `svg` fenced block from the latest
assistant answer, or the current editable HTML/SVG Document Canvas, as a
read-only visual artifact. This is a conversation/document-review feature, not
a project editor or code runner.

## Trust boundary

Assistant output is untrusted. Preview must never execute script, submit forms,
load local files, contact the network, navigate another window, or gain access
to the Lens process. Lens never previews an arbitrary filesystem HTML file in
this path. Preview input is either the latest complete labelled assistant block
or the explicit in-memory HTML/SVG Canvas draft.

## V1 isolation layers

1. Accept only fenced blocks labelled `html`, `htm`, or `svg`, or an explicitly
   typed HTML/SVG Canvas, capped at 256 KiB.
2. Fail closed when active content, event handlers, navigation/resource
   attributes, external schemes, unsafe CSS fetches, or active SVG primitives
   are present. No rewriting or best-effort sanitization is attempted.
3. Write a generated content document with a restrictive Content Security
   Policy: no scripts, images, fonts, media, objects, frames, connections,
   forms, or base-URL changes; inline CSS is the only resource allowed.
4. Open that content inside a separate generated wrapper using a sandboxed
   iframe with no `allow-*` permissions and no referrer.
5. Store generated files only in portable `chats\artifacts\`; names are generated
   by Lens and never derived from assistant text.
6. Launch the wrapper through the Windows default browser. No browser engine,
   WebView runtime, Node.js, Python, Ollama, or other third-party runtime is
   bundled or required by Lens.

## Fail-closed exclusions

V1 rejects scripts; event attributes; frames; objects/embeds; forms and inputs;
active metadata (`http-equiv`), base/link tags; media; external images; `foreignObject`; SVG use/image/
animation/filter primitives; `href`, `src`, action and poster attributes; HTTP,
HTTPS, FTP, file, JavaScript, VBScript and data schemes; CSS imports,
expressions, bindings, external image functions, and non-fragment `url()`.

This deliberately rejects some harmless documents. Safety and a clear reason
take priority over trying to repair arbitrary markup. SVG fragment paint such
as `fill="url(#gradient)"` remains allowed, as is exactly the inert standard
`xmlns="http://www.w3.org/2000/svg"` namespace declaration. It does not grant
network access; every other HTTP(S) or protocol-relative token remains blocked.

## User experience

- Transcript context menu: **Preview last HTML/SVG artifact**.
- HTML/SVG Canvas: **Safe Preview** validates the current edited source through
  this same policy before creating any preview files.
- A rejected block remains available through Copy/Save and receives an explicit
  status message; Lens does not silently weaken the policy.
- The wrapper visibly labels the result as a sandboxed, read-only Lens artifact.
- Closing the browser leaves only the small portable artifact files; they may be
  removed with chat/cache cleanup in a later Privacy Proof milestone.

## Future changes

Any relaxation must add a regression fixture first. Native in-process HTML
engines, script execution, network access, arbitrary local-file preview, and
Studio/Pad build/run integration are outside this contract.
