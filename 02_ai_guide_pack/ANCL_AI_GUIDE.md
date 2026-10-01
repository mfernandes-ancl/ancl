# ANCL — A Practical Guide for Writing Programs (for an AI)

You are going to write a program in **ANCL**, a small, statically-typed systems language that
compiles **directly to a native x86-64 Windows `.exe`** (PE32+) with **no runtime, no VM, no
interpreter, and no C runtime (CRT)** — it links only Win32 DLLs you ask for. This guide is
distilled from the real ANCL compiler's own source and test suite, so everything here compiles.

> Compile & run:  `bin\anclc.exe myapp.ancl myapp.exe`  then  `myapp.exe`
> (Optional icon:  `bin\anclc.exe myapp.ancl myapp.exe myicon.ico`)

---

## 1. Program skeleton

```ancl
# '#' starts a line comment. There are no block comments.

@DATA                      # the data section: globals & string/number constants
greeting: str = "Hello, ANCL!\n";
count:    i64 = 3;

@CODE                      # the code section: functions
func main() -> i32 {       # entry point MUST be `func main() -> i32`
    syscall 1, greeting;   # print a string to stdout (see I/O below)
    return 0;              # exit code
}
```

Every program has a `@DATA` section (globals) and a `@CODE` section (functions), and a
`func main() -> i32`. Type declarations (`struct` / `sum`) may appear at the very top of the file,
before `@DATA`.

---

## 2. Types

| Type   | Meaning                                              |
|--------|------------------------------------------------------|
| `i64`  | 64-bit signed integer (the default integer)          |
| `i32`  | 32-bit signed integer                                |
| `i16`  | 16-bit signed integer                                |
| `i8`   | 8-bit signed integer / byte                          |
| `f64`  | 64-bit IEEE double (the ONLY float type; no f32)     |
| `ptr`  | raw pointer (a 64-bit address)                       |
| `str`  | pointer to a null-terminated string literal          |
| `buf`  | a fixed-size, zero-filled global byte buffer (BSS)   |

There is **no bool** — use `i64` (0 = false, non-zero = true).
There is **no string class** — a `str` is just a pointer to bytes ending in `\0`.

---

## 3. Globals (`@DATA`)

```ancl
@DATA
title:   str = "Report\n";       # string literal (supports \n, \t, \" escapes)
limit:   i64 = 100;
pi_x100: i64 = 314;
magic:   i64 = 0x4D594741;       # hex literals are fine
slope:   f64 = 0.01;             # f64 constant
scratch: buf = 256;              # a 256-byte zeroed buffer; `scratch` is its address
```

A `buf = N` global is N bytes of zeroed memory; the name evaluates to its **address** (a pointer),
which you read/write with the `load*`/`store*` intrinsics (Section 7).

### Compile-time const-expressions in `@DATA`

Any integer initializer (and a `buf` size) may be a **constant expression**, folded at compile time:

```ancl
LIMIT: i64 = 0 - 1;             # unary minus / subtraction
MAXSZ: i64 = 1024 * 64;         # arithmetic  + - * / %
FLAGS: i64 = 0x1 | 0x4 | 0x10;  # bitwise  | & ^
MASK:  i64 = (1 << 8) - 1;      # shift << >> + parens (full C precedence)
ring:  buf = 4 * 4096;          # const-expr buf size
```

### Initialized data arrays (read-only tables)

`name: T[N] = { e0, e1, ... }` lays out a static, **read-only** table of N `T`-width slots
(`i8`/`i16`/`i32`/`i64`/`ptr`; no `f64` arrays yet). The name is the array's **address** (like a `buf`).
Elements are const-expressions; a short initializer **zero-fills** the remainder.

```ancl
opcodes: i8[4]  = { 0x01, 0x03, 0x06, 0x10 };          # 1 byte per slot
sine:    i64[4] = { 0, 4096, 0, 0 - 4096 };            # const-expr element
masks:   i32[3] = { 0x1 | 0x2, (1 << 8) - 1, 0xFF };   # 4-byte slots
short:   i64[4] = { 7, 9 };                            # -> { 7, 9, 0, 0 }
```

Read them with `load*` or a typed pointer (Section 9) — they're constant tables, so don't write to them:

```ancl
v = load64(sine + 2 * 8);    # element 2
p: *i8 = opcodes;            # typed-pointer view
fc = p[1];                   # 0x03
```

---

## 4. Functions & variables

```ancl
@CODE
func add(a: i64, b: i64) -> i64 {
    return a + b;
}

func main() -> i32 {
    x = add(2, 3);     # FIRST assignment declares a local — no `let`/`var` keyword
    x = x + 1;         # locals are untyped i64 by default
    return 0;
}
```

- Parameters are typed: `name: type`. Return type after `->`.
- A function with no useful return still declares one, e.g. `-> i64`, and ends with `return 0;`.
- A local variable is created by its **first assignment**; it is `i64` unless you annotate it
  (`p: ptr = ...;`). Reassign freely.
- Functions may be called before they are defined (whole-file resolution). Recursion is allowed.

---

## 5. Control flow

```ancl
# if / else / else if
if x > 0 {
    syscall 1, pos;
} else {
    syscall 1, nonpos;
}

# while  (the conditional loop)
i = 0;
while i < 10 {
    syscall 1, dot;
    i = i + 1;
}

# while 1 { ... break; }  is the idiomatic INFINITE loop
while 1 {
    c = read_char();
    if c == 0 { break; }      # `break` exits the nearest loop
}

# loop N { ... }  also exists as an infinite loop (exit via return/break)
loop 1 {
    if done == 1 { return 0; }
}
```

There is **no `for` loop** — use `while` with a manual counter.

`&&` and `||` work like C and **short-circuit** — the right side is skipped once the left
decides the result, so they're the safe way to guard a load:

```ancl
if a > 0 && b > 0   { syscall 1, both; }          # AND
if a == 1 || b == 2 { syscall 1, either; }        # OR
if p != 0 && load64(p) > 0 { syscall 1, ok; }     # load64 runs only when p != 0

# else if chains:
if x > 0      { syscall 1, pos; }
else if x < 0 { syscall 1, neg; }
else          { syscall 1, zero; }
```

---

## 6. Operators

- Arithmetic: `+  -  *  /  %`   (`/` and `%` are integer division/remainder for ints)
- Comparison: `==  !=  <  >  <=  >=`
- Logical (short-circuit, C-like): `&&  ||`   (operands are `i64`: 0 = false, non-zero = true)
- Bitwise (infix): `|  &  ^  <<  >>`   — or the intrinsic forms `bor(a,b)`, `band(a,b)`,
  `bxor(a,b)`, `shl(x,n)`, `shr(x,n)`.
- **Unary minus** `-x` works (it desugars to `0 - x`); the explicit `0 - x` form is equally valid and common in older code.
- `%` binds tighter than `==`, so `i % 15 == 0` parses as `(i % 15) == 0`.

---

## 7. Memory & numeric intrinsics (the low-level toolbox)

```ancl
load8(p)   load32(p)   load64(p)      # read 1/4/8 bytes at address p
store8(p,v)  store32(p,v)  store64(p,v)  # write 1/4/8 bytes at address p

itof(i)    # i64  -> f64
ftoi(f)    # f64  -> i64 (truncates toward zero)
sqrt(f)    # f64 square root
fbits(f)   # reinterpret an f64 as its raw i64 bits  (to STORE an f64)
ffrombits(i) # reinterpret raw i64 bits as an f64    (to LOAD an f64)
strlen(s)  # length of a null-terminated string
```

Pointers are plain integers, so **pointer arithmetic is integer math**: the i-th 8-byte slot of
buffer `b` is `b + i * 8`. To keep an f64 in memory you store its bits and read them back:

```ancl
store64(b + i * 8, fbits(3.14));            # write an f64
v = ffrombits(load64(b + i * 8));           # read it back
```

f64 **arithmetic is direct** — `a + b`, `a * b`, `sqrt(x)`, and comparisons all work on f64
values (and f64 args/returns ride XMM registers automatically). You only need `fbits`/`ffrombits`
to *park* an f64 in an i64-shaped slot (a `buf`, a struct field, a raw `store64`).

---

## 8. Input / Output (builtins — no import needed)

```ancl
syscall 1, s;              # print string s to stdout
syscall 1, s, n, s2;       # TYPE-AWARE: prints string s, then integer n (as decimal), then s2
c = read_char();           # read one byte from stdin; returns 0 at end-of-input (EOF)
n = read_int();            # parse an integer from stdin
```

`syscall 1, ...` takes any number of args and prints each by **static type**: a `str` prints as
text, an `i64` prints as a decimal number. (It does not format f64 — convert/format floats yourself.)

**Important:** only a `str` prints as text. A `buf` or `ptr` argument prints as its **address number**,
NOT its contents. So to print text you assembled in a `buf`, either emit it one character at a time
(a `str` constant per character, e.g. `hash: str = "#";`) or write the bytes with Win32 `WriteFile`
(`WriteFile(GetStdHandle(0 - 11), mybuf, length, nio, 0)`).

---

## 9. Structs (zero-cost field offsets)

```ancl
struct Point { x: i32; y: i32; tag: i64; }   # fields are laid out in order, naturally packed

@DATA
store: buf = 64;

@CODE
func main() -> i32 {
    p = store;                       # use any buffer/pointer as the struct's storage
    store32(p + Point.x, 100);       # `Point.x` is the COMPILE-TIME byte offset of field x (0)
    store32(p + Point.y, 200);       # Point.y -> offset 4
    store64(p + Point.tag, 99999);   # Point.tag -> offset 8
    syscall 1, lbl, load32(p + Point.x), nl;   # read a field back
    return 0;
}
```

`sizeof(Point)` gives the struct size; `Point.field` gives a field's byte offset; array fields like
`data: i8[61]` and `sizeof(i32[10])` are supported. Structs are *just* offset constants — you place
them over any memory and use `load*`/`store*`.

### Typed pointers — `p.field` and `a[i]` (less boilerplate)

Annotate a local with a pointer type and the compiler does the offset/stride math for you. Both
forms compile to the *exact* `load*`/`store*` you'd write by hand — just less error-prone:

```ancl
p: *Point = store;     # typed pointer to a Point laid over `store`
p.x = 100;             # same as store32(p + Point.x, 100)
p.y = 200;
v = p.x;               # read a field

vals: *i64 = scratch;  # a typed pointer used as an array (stride = 8)
vals[0] = 11;          # same as store64(scratch + 0*8, 11)
vals[3] = 44;
n = vals[3];           # read element 3
```

Chaining works too: `p.next.tag`, `rows[i].field`, `grid[i].ports[j]` (read and write).

---

## 10. Sum types + `match` (tagged unions)

```ancl
sum Shape { Circle(r: i32), Rect(w: i32, h: i32), Empty }   # a value is a heap ptr: tag@0, fields@8

func area(s: Shape) -> i64 {
    match s {
        Circle(r)  => { return r * r * 3; }    # binds the variant's fields as locals
        Rect(w, h) => { return w * h; }
        Empty      => { return 0; }
        _          => { return 0 - 1; }         # `_` is the default arm
    }
    return 0;
}

func main() -> i32 {
    c = Shape.Circle(10);        # construction; heap-allocates
    syscall 1, lbl, area(c), nl; # 300
    free(c);                     # sum values are heap-allocated -> free when done
    return 0;
}
```

`match` also works as an integer `switch`:

```ancl
match code {
    1 => { return 100; }
    2 => { return 200; }
    _ => { return 0 - 1; }      # default
}
```

---

## 11. Calling Win32 (FFI) — for files, memory, windows, sockets, etc.

```ancl
extern "kernel32.dll" GetStdHandle -> ptr;   # declare an imported function (+ return type)
extern "kernel32.dll" WriteFile;             # no `-> type` = return ignored
extern "kernel32.dll" VirtualAlloc -> ptr;

@DATA
nio: buf = 8;                                # out-param scratch (bytes-written)
msg: str = "low-level write\n";

@CODE
func main() -> i32 {
    h = GetStdHandle(0 - 11);                # STD_OUTPUT_HANDLE == -11
    WriteFile(h, msg, strlen(msg), nio, 0);  # standard Win64 args, left-to-right
    return 0;
}
```

Win32 calls use the native x86-64 calling convention; pass arguments left-to-right (f64 args go in
XMM registers automatically). Allocate memory with `VirtualAlloc(0, bytes, 0x3000, 4)`
(MEM_COMMIT|RESERVE, PAGE_READWRITE) — committed pages are zero-filled.

---

## 12. The rules that trip people up (READ THIS)

1. **No `for`** → use `while` + a counter.  (`if` / `else` / `else if` all work.)
2. **`&&` / `||` exist and short-circuit** (C-like) — use them; operands are `i64` truth values.
3. **Unary minus** `-x` works (desugars to `0 - x`); `0 - x` is the older explicit form.
4. **No bool / no string type** → `i64` for truth; `str`/pointer + `\0` for text.
5. **Floats live as bits in memory**: `store64(p, fbits(v))` to write, `ffrombits(load64(p))` to read.
   Only `f64` exists (no `f32`).
6. First assignment declares a local; no `let`/`var`.
7. `main` must be `func main() -> i32` and `return` an exit code.
8. Output is `syscall 1, ...` (strings + ints). Input is `read_char()` / `read_int()`.
9. Buffers (`buf = N`) and `VirtualAlloc` give you raw memory you index with `load*`/`store*`.
10. Keep it CRT-free: there is no `printf`, `malloc` (use `VirtualAlloc` or sum-type heap), `strcpy`,
    etc. — build what you need from the intrinsics, or call Win32.

---

## 13. Two complete, compilable examples

**A. Hello world**
```ancl
@DATA
banner: str = "==============================\n";
msg:    str = " Hello from ANCL!\n Native x86-64 Windows PE, no CRT.\n";

@CODE
func main() -> i32 {
    syscall 1, banner;
    syscall 1, msg;
    syscall 1, banner;
    return 0;
}
```

**B. FizzBuzz 1..20** (shows `while`, `%`, `else if`, and type-aware printing)
```ancl
@DATA
s_fizz: str = "Fizz\n";
s_buzz: str = "Buzz\n";
s_fb:   str = "FizzBuzz\n";
nl:     str = "\n";

@CODE
func main() -> i32 {
    i = 1;
    while i <= 20 {
        if i % 15 == 0     { syscall 1, s_fb; }
        else if i % 3 == 0 { syscall 1, s_fizz; }
        else if i % 5 == 0 { syscall 1, s_buzz; }
        else               { syscall 1, i, nl; }   # print the number itself
        i = i + 1;
    }
    return 0;
}
```

---

## 14. Core library quick map

This guide is reference context for an AI assistant, not a task prompt. Give the model a separate
task after this guide. Prefer importing existing core helpers instead of recreating them by hand.

- `core_lib/std.ancl`: small integer helpers such as `imin`, `imax`, `iabs`, `clamp`, and `ipow`.
- `core_lib/cstring.ancl`: bounded copy, quoted command-line append, and compact truthy parsing.
- `core_lib/numfmt.ancl`: unsigned decimal formatting, fixed-width digits, sign extension helpers,
  and integer-only f64/OLE-date formatting helpers.
- `core_lib/win32_api.ancl`: common Win32 imports and constants for files, processes, windows,
  painting, timers, handles, and memory.
- `core_lib/process.ancl`: process launch helpers.
- `core_lib/process_capture.ancl`: hidden child-process launch with stdout/stderr capture.
- `core_lib/gui.ancl` and `core_lib/gui_v2.ancl`: native Win32 controls, menus, list views,
  file dialogs, clipboard helpers, and message-loop utilities.
- `core_lib/gdi.ancl` and `core_lib/gdi_v2.ancl`: brushes, pens, fonts, drawing helpers, and
  double-buffered UI patterns.
- `core_lib/rich_edit.ancl`: RichEdit loading, creation, text limits, formatting, undo/redo,
  selection, and paragraph helpers.
- `core_lib/editor_gutter.ancl` and `core_lib/syntax_ancl.ancl`: editor line-number gutter and
  ANCL syntax-highlighting helpers used by ANCL Pad.
- `core_lib/sqlite.ancl`: SQLite interop wrapper for native tools that need an embedded database.
- `core_lib/mqtt.ancl`: plain MQTT packet/connect/publish helpers.
- `core_lib/iec61850.ancl`: IEC 61850-oriented protocol helpers.
- `core_lib/win32_com.ancl`: COM/OLE helpers, including `vmeth`, `com_qi`, `com_addref`,
  `com_release`, and ANSI-to-wide conversion.

When generating ANCL, first decide whether the program is a console tool, a Win32 GUI tool, a
protocol/network tool, or a process/database utility, then import the closest core library. Keep the
answer complete and compilable, and always re-check it against Section 12 before final output.

## 15. Compiler feature differences and updated core helpers

The preserved self-hosted release compiler and optional `01_compiler/bootstrap/anclc.cpp`
are not feature-equivalent. The newer bootstrap supports f32 storage/FFI widened to f64
computations and fixes typed floating-point struct/array accesses. Do not apply that feature
set to an arbitrary older executable. The baseline release fails the new f64-struct/f32
regressions even though it reproduces its own self-host fixpoint.

The compiler/AI-guide core bundles include `heap.ancl` (caller-region allocation) and
`libsha256.ancl` (SHA-256, HMAC, HKDF), plus JSON number-token, Unicode, member-walk and
capacity helpers. `json_num_bits` returns f64 bits; `json_num_copy` capacity includes the
terminating NUL. Keep the source document alive for number-token APIs; parse/reserve
invalidates previous shared DOM/arena state. This JSON reader is permissive, not a strict
malformed-input validator. Shared scratch helpers are not automatically thread-safe.

For precise APIs, dependency exceptions and compiler selection, see
`01_compiler/DEVELOPER_REFERENCE.md`, `CAPABILITIES.md` and `VALIDATION.md` in the repository.
These are unversioned source/core improvements; they do not replace the release executables
or claim production hardening. Compilation and runtime assertions settle syntax validity.
