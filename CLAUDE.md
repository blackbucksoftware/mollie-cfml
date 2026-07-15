# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

**mollie-cfml** is a CFML (ColdFusion/Lucee) client library for the [Mollie](https://mollie.com) Payment Service Provider API v2. It ships as a CommandBox package (`molliecfml`) that works both standalone and as a ColdBox module. The entire public surface lives in a single file, [mollie.cfc](mollie.cfc).

## Commands

Tooling is driven by [CommandBox](https://www.ortussolutions.com/products/commandbox) and the scripts in [box.json](box.json):

```bash
# Install dev dependencies (testbox, coldbox) into their installPaths
box install

# Format source in place (rewrites the files)
box run-script format

# Check formatting without writing
box run-script format:check

# Run the test suite (start a server, then hit the runner)
box server start
# tests run via http://127.0.0.1:45000/tests/runner.cfm (see box.json testbox.runner)
```

Formatting rules are enforced by [cfformat](https://github.com/foundeo/commandbox-cfformat) using [.cfformat.json](.cfformat.json) — notably **tab indentation**, 120-column max, double-quoted strings, and `" : "` struct separators. Run `format` before committing changes to `mollie.cfc` or `ModuleConfig.cfc`.

## Architecture

### Single-component design

All API coverage is a flat set of ~50 public methods on [mollie.cfc](mollie.cfc), one per Mollie API operation (`createPayment`, `listRefunds`, `getSettlement`, etc.). The README table maps every method to its Mollie API endpoint. The component is **tag-based CFML** (`<cffunction>`, `<cfhttp>`, `<cftry>`) with `<cfscript>` blocks inside methods for request-body construction — match this style when adding methods; do not rewrite existing methods to script syntax.

### The uniform method pattern

Every API method follows the same shape, so a new endpoint is a copy-paste-and-adjust of an existing one:

1. `response = this.GetNewResponse()` — returns the standard envelope `{ success: true, error: [], data: "" }`.
2. A `<cfhttp>` call to `#variables.instance.baseUrl#/<endpoint>` with an `Authorization: Bearer #variables.instance.key#` header.
3. Optional query params added conditionally via `<cfif structKeyExists(arguments, "x")>` guards (this is how optional args are kept out of the request when absent).
4. `response.data = deserializeJSON(mollieresult.filecontent)` on success.
5. `<cfcatch>` sets `response.success = false`, `response.error = cfcatch.message`, and writes to the `mollie` log file via `<cflog file="mollie" text="Error in <methodName>: ...">`.

**Every method returns the same envelope** — callers check `.success` and read `.data`/`.error`. Preserve this contract; do not return raw Mollie payloads.

### Conventions worth preserving

- **Auth & base URL** live in `variables.instance` (`key`, `baseUrl`), set once in `init()`. `baseUrl` defaults to `https://api.mollie.com/v2`.
- **POST bodies** are built as a nested struct (often under a `dataFields.Globals` key), then `serializeJSON`'d and sent as a `<cfhttpparam type="body">`.
- **`fullurl` argument**: the settlement-list methods (`listSettlementPayments`, `listSettlementRefunds`, `listSettlementChargebacks`) accept an optional `fullurl` arg — when non-empty it is used as the complete request URL, supporting pagination via Mollie's `_links.next.href`. Recent work has been extending this pattern; follow it when adding paginated list methods.
- **`localmode="modern"`** is set on nearly all methods so unscoped vars inside `<cfscript>` are function-local.
- **`timeout="30"`** is set on select `<cfhttp>` calls; most list/get calls omit it.
- Test keys and live keys are both accepted — the library does not distinguish them.

### Standalone vs. ColdBox module

- **Standalone**: `new mollie(key=..., baseUrl=...)`.
- **ColdBox module**: [ModuleConfig.cfc](ModuleConfig.cfc) maps the singleton `mollie@molliecfml` and reads `key`/`baseUrl` from `moduleSettings.molliecfml`. Injectable via `inject="mollie@molliecfml"`. Any change to constructor args must be reflected in `ModuleConfig.onLoad()`.

## Tests

Test specs are TestBox BDD specs expected under `tests/specs/` (per the `format` script glob), but the suite is currently minimal — the README lists "Write more tests" as a todo. `tests/resources/app/coldbox/` and the top-level `testbox/` directory are **vendored dependencies** (installed via `box install`); do not edit or review code there. `MOLLIE_KEY` is supplied via a `.env` file (see [.env.example](.env.example)) for live-key integration testing.

## Versioning

`box.json` `version` is the published package version; releases are tagged (`git tag vX.Y.Z`) and committed with a `🚀 RELEASE: vX.Y.Z` message. Bump `box.json` when cutting a release.
