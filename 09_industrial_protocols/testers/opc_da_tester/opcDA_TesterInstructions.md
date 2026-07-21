# SYSTEM PROMPT / ARCHITECTURAL TRIAGE: ANCL V6 OPC CLIENT PURIFICATION

## 1. COMPILER ENVIRONMENT & CURRENT CRITICAL ERROR
- **Toolchain:** ANCL V6 (Zero-CRT, PE32+ Bare-Metal Windows Compiler, unmanaged code).
- **Target File:** `showcase/opc_da_tester/opc_client.ancl`
- **Current Blocker:** Compiling the three-import matrix (`win32_com.ancl` + `win32_api.ancl` + `opc_client.ancl`) triggers an immediate compiler failure: `"unexpected top-level token"`. 
- **Root Cause:** Syntactical non-compliance inside `opc_client.ancl` (stray tokens, invalid comments, or illegal syntax sitting outside strict memory blocks) causing parser misalignment during multi-unit compilation.

## 2. STRUCTURAL MANDATE & SANITIZATION POLICIES
You must completely strip and rewrite `opc_client.ancl` to enforce an absolute, non-negotiable ANCL V6 top-to-bottom layout:

```ancl
// ============================================================================
// 1. TOP-LEVEL IMPORTS
// ============================================================================
import "win32_api.ancl";
import "win32_com.ancl";

// ============================================================================
// 2. GLOBAL SYSTEM MEMORY SEGMENT
// ============================================================================
@DATA
// All global variables, GUID allocations, and struct instances go here.
// Absolutely NO executable code, loops, or inline logic allowed in this segment.

// ============================================================================
// 3. EXECUTABLE LOGIC SEGMENT
// ============================================================================
@CODE
// All functions, execution hooks, and procedural routines go here.