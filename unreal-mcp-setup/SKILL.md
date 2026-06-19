---
name: unreal-mcp-setup
description: Set up or troubleshoot the Unreal Engine 5.8 Model Context Protocol (MCP) server so Claude Code can drive the Unreal Editor. Use when a user is connecting Claude Code to Unreal Engine, sees only the AgentSkillToolset (missing Scene/Actor/Blueprint toolsets), gets "could not connect" / no MCP tools, has port/.mcp.json questions, or asks how to wire UE to Claude. UE 5.8 specific.
---

# Unreal Engine 5.8 + Claude Code (MCP) Setup

Goal: Claude Code drives the Unreal Editor via the built-in MCP server, with the
full ~50 editor toolsets exposed (Scene, Actor, Blueprint, Material, etc.).

A human-facing rendered version of this guide is in `index.html` (open in a browser).
This `SKILL.md` is the canonical content — use it to walk a user through setup or
diagnose a broken connection.

## #1 most common failure (check this first)
If `list_toolsets` shows **only `AgentSkillToolset`**, the feature toolsets are not
loaded. Fix: enable the **All Toolsets** plugin, restart the editor, then run
`ModelContextProtocol.RefreshTools` in the editor's **Cmd** console. The Unreal MCP
plugin alone only ships the native AgentSkillToolset; the real editor toolsets are
separate (Python) plugins that "All Toolsets" aggregates.

## Setup steps

### 0. Prerequisites
- Unreal Engine **5.8** (these MCP plugins are 5.8-experimental).
- A UE project (C++ or Blueprint-only both work).
- Claude Code installed, runnable from a terminal.

### 1. Enable plugins (`Edit → Plugins`), then restart the editor
- **Unreal MCP** — the MCP server.
- **Toolset Registry** — auto-enabled as a dependency.
- **All Toolsets** ⭐ — aggregator that pulls in every editor toolset. Without it you
  only get skill management.
- **Python Editor Script Plugin** — the editor toolsets are authored in Python.

Notes:
- "MCP Client Toolset" is the opposite direction (UE as a client to other MCP
  servers) — not needed; harmless if on.
- Enabling All Toolsets may prompt: *"Asset Manager … GameFeatureData … Add entry?"*
  → click **Yes** (harmless).

### 2. Configure the server (`Edit → Editor Preferences → General → Model Context Protocol`)
- **Server Url Path**: `/mcp`
- **Server Port Number**: `8000` (default) — or a custom port like `8137` if 8000 is taken.
- **Auto Start Server**: ON (binds on editor launch).
- **Enable Tool Search**: ON (required — how Claude discovers the tools).

### 3. Client config — create `.mcp.json` in the project root (next to `.uproject`)
```json
{
  "mcpServers": {
    "unreal-mcp": {
      "type": "http",
      "url": "http://127.0.0.1:8000/mcp"
    }
  }
}
```
- Port here MUST match the editor port from step 2.
- If other MCP servers already exist in the file, merge this entry into `mcpServers` — don't overwrite.
- Editor shortcut to generate it: Cmd console → `ModelContextProtocol.GenerateClientConfig ClaudeCode`.

### 4. Start the server & verify it's live
- Auto Start handles it; manual start: Cmd console → `ModelContextProtocol.StartServer`.
  (The console dropdown must be **Cmd**, not Python.)
- Verify from a terminal: `curl -sS http://127.0.0.1:8000/mcp`
  - HTTP **405 Method Not Allowed** = server is UP and speaking MCP (405 is expected for a plain GET). Good.
  - "Could not connect" = server not running → re-check steps 1–2.

### 5. Start/restart Claude Code — ORDER MATTERS
Bring the editor server up FIRST, then start Claude Code. Claude reads the MCP server
list at launch; if the port wasn't live at startup, it won't connect. After editing
`.mcp.json` or starting the server, restart Claude Code.

### 6. Verify
Claude should have meta-tools `list_toolsets`, `describe_toolset`, `call_tool`.
`list_toolsets` should return **~50 toolsets** including `SceneTools`, `ActorTools`,
`BlueprintTools`, `ObjectTools`, `MaterialTools`, `BehaviorTreeTools`, `NiagaraToolsets`,
`UMGToolSet`, `PCGToolset`, `AutomationTestToolset`. If only `AgentSkillToolset` → see "#1" above.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Only `AgentSkillToolset` shows | Enable **All Toolsets** + restart editor; run `ModelContextProtocol.RefreshTools`. (#1 issue.) |
| Claude sees no MCP tools at all | Server wasn't live when Claude started, or `.mcp.json` wrong/missing. Verify with `curl`, fix, restart Claude AFTER server is up. |
| `curl` → "could not connect" | Server not running → `ModelContextProtocol.StartServer`; confirm Auto Start on; port must match `.mcp.json`. |
| Port 8000 in use | Pick another port in Editor Preferences AND update `.mcp.json` — they must be identical. |
| "Add GameFeatureData entry?" dialog | Click **Yes** (harmless, Game Features toolset). |
| Console command does nothing | Console dropdown must be **Cmd**, not Python. |
| Changed setting/plugin, no effect | Plugin/port changes need an editor restart; client config changes need a Claude Code restart. |

## How it fits together
Claude Code → (`.mcp.json`: `http://127.0.0.1:<port>/mcp`) → Unreal MCP server (in UE Editor)
→ Toolset Registry → { `AgentSkillToolset` (native, always) + the Python editor toolsets
(Scene/Actor/Blueprint/Material/Object/…) registered via **All Toolsets** }.

- Tool Search mode (on by default) keeps `tools/list` small — Claude gets 3 discovery
  meta-tools and pulls specific tool schemas on demand. Leave it on.
- Toolsets are discovered at editor **startup** (and on `RefreshTools`); plugin changes
  need a restart to register.

## One-line answer when a teammate is stuck
Enable **All Toolsets**, restart the editor, restart Claude.
