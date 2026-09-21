{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "1c": {
      "type": "remote",
      "url": "http://localhost:6003/mcp",
      "enabled": true
    },
    "edt": {
      "type": "remote",
      "url": "http://localhost:8765/mcp",
      "enabled": true
    },
    "obsidian": {
      "type": "local",
      "command": ["cmd", "/c", "mcpvault", "{{OBSIDIAN_VAULT}}"],
      "enabled": true
    },
    "excel": {
      "type": "local",
      "command": ["cmd", "/c", "uvx", "excel-mcp-server", "stdio"],
      "enabled": true
    },
    "dxf": {
      "type": "local",
      "command": ["cmd", "/c", "{{AIBLUEPRINT_EXE}}"],
      "enabled": true,
      "environment": {
        "AIBLUEPRINT_WORKSPACE": "{{AIBLUEPRINT_WORKSPACE}}"
      }
    }
  },
  "permission": {
    "external_directory": {
      "{{OBSIDIAN_VAULT}}/**": "allow"
    }
  },
  "experimental": {
    "mcp_timeout": 30000
  }
}