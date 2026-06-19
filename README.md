# my-skills

A collection of **Claude Code skills** I build and reuse. Each skill is a self-contained
folder Claude reads off disk — no hosting, no copy-paste, works offline.

## What's in here

| Skill | What it does |
|---|---|
| [`unreal-mcp-setup`](./unreal-mcp-setup) | Set up / troubleshoot the Unreal Engine 5.8 MCP server so Claude Code can drive the Unreal Editor. Includes a human-facing HTML guide (`index.html`) + screenshots. |

## How a skill is structured

```
<skill-name>/
├── SKILL.md      # required — YAML frontmatter (name + description trigger) + the content
├── index.html    # optional — a human-facing rendered version
└── images/       # optional — assets
```

The `description` in `SKILL.md`'s frontmatter is what tells Claude **when** to use the
skill, so write it as triggers ("use when …").

## Install a skill

Copy the skill folder into one of Claude Code's skills directories, then restart Claude Code.

**Global (available in every project):**
```bash
cp -r unreal-mcp-setup ~/.claude/skills/
```

**Per-project (shared with a repo via git):**
```bash
cp -r unreal-mcp-setup <your-project>/.claude/skills/
```

On Windows the global path is `C:\Users\<you>\.claude\skills\`.

Skills load at startup — **restart Claude Code** after copying, and the skill triggers
automatically when its description matches what you ask.

## Add a new skill

1. `mkdir <skill-name>` and add a `SKILL.md` with frontmatter:
   ```markdown
   ---
   name: my-skill
   description: One-line summary of what it does and WHEN to use it (triggers).
   ---

   # Content Claude should follow…
   ```
2. (Optional) add an `index.html` + `images/` for a human-facing version.
3. Commit & push. Add a row to the table above.
