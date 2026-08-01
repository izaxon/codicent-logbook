# Codicent Logbook

A standalone, zero-dependency logbook runtime that ships as a single self-contained
executable. SQLite storage, MCP server (stdio + HTTP), REST API with OpenAPI schema,
file inbox, and public tunnel support. Works with Claude Desktop, Cursor, and any
MCP client.

**Website & docs: https://logbook.codicent.ai/**

## Install

Linux / macOS:

```bash
curl -fsSL https://logbook.codicent.ai/install.sh | bash
logbook-server
```

Windows (PowerShell):

```powershell
iwr https://logbook.codicent.ai/install.ps1 | iex
logbook-server
```

Or download a binary directly from [Releases](https://github.com/izaxon/codicent-logbook/releases/latest):
`logbook-server-linux-x64`, `logbook-server-linux-arm64`, `logbook-server-osx-arm64`,
`logbook-server-osx-x64`, `logbook-server-win-x64.exe`.

Then open http://localhost:5100 — the MCP endpoint is at `/mcp`.

## About this repository

This repository hosts the **website, install scripts, and binary releases** for
Codicent Logbook. The source code lives in the `codicent-logbook/` project of the
Codicent monorepo, and this repo's content is synced from there automatically —
please don't open PRs against the site files here.

Issues and feature requests are welcome in this repo's
[issue tracker](https://github.com/izaxon/codicent-logbook/issues).

## Links

- [Website](https://logbook.codicent.ai/) — features, quick start, MCP tools, configuration
- [Releases](https://github.com/izaxon/codicent-logbook/releases) — self-contained binaries for all platforms
- [codicent.com](https://codicent.com) — the full Codicent platform
