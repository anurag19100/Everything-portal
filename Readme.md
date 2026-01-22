# Everything Portal

A comprehensive VS Code workspace configuration project with integrated Claude AI assistant support for enhanced development workflows.

## Overview

**Everything Portal** is a development environment setup that combines VS Code customizations with Claude AI capabilities to streamline coding tasks, automate workflows, and provide intelligent assistance across multiple programming languages.

## Features

✨ **Key Features:**

- **Claude AI Integration** - Seamless integration with Claude Code Assistant for intelligent code completion and analysis
- **Web Search Capabilities** - Access to web search within Claude Chat for up-to-date information
- **Auto-Approve Settings** - Pre-configured auto-approval for common development tasks
- **Multi-Language Support** - Optimized configuration for Python, JavaScript, SQL, Shell scripts, and more
- **Local Customization** - Workspace-specific settings in `.claude/settings.local.json` for granular control
- **Security Permissions** - Git-based permission management for safe command execution

## Project Structure

```
Everything-portal/
├── Readme.md                          # Project documentation (this file)
├── .vscode/
│   └── settings.json                  # VS Code workspace settings
└── .claude/
    └── settings.local.json            # Claude-specific permissions and settings
```

## Setup Instructions

### Prerequisites

- Visual Studio Code (latest version recommended)
- Claude Code extension installed
- Git (for version control and permissions management)

### Installation

1. **Clone or open this workspace:**

   ```bash
   cd Everything-portal
   code .
   ```

2. **Verify extensions are installed:**
   - Claude Code extension (GitHub Copilot/Claude AI)
   - Prettier (code formatter)
   - Other language-specific extensions

3. **Check workspace settings:**
   - VS Code will automatically load settings from `.vscode/settings.json`
   - Claude-specific settings load from `.claude/settings.local.json`

## Configuration

### VS Code Settings (`.vscode/settings.json`)

The workspace includes pre-configured settings for:

- **Claude Integration:**

  ```json
  {
    "claudeCode.initialPermissionMode": "acceptEdits",
    "github.copilot.chat.anthropic.tools.websearch.enabled": true,
    "chat.useAgentSkills": true
  }
  ```

- **Editor Defaults:** Auto-formatting and formatting on save
- **Language Formatters:** Python, JavaScript, SQL, Shell scripts
- **Git Integration:** Smart commit with auto-sync

### Claude Permissions (`.claude/settings.local.json`)

Secure permission whitelist for Claude operations:

```json
{
  "permissions": {
    "allow": [
      "Bash(git -C /root/ws/Everything-portal log --oneline -20)",
      "Bash(git -C /root/ws/Everything-portal log --all --graph --oneline)",
      "Bash(git -C /root/ws/Everything-portal status)",
      "Bash(git -C /root/ws/Everything-portal show:*)",
      "Bash(git -C /root/ws/Everything-portal config --list)",
      "Bash(xargs cat:*)",
      "Bash(git -C /root/ws log --all --graph --oneline --decorate)"
    ]
  }
}
```

## Supported Languages & Tools

- **Python** - ms-python formatter with format-on-type
- **JavaScript** - Prettier formatter
- **JSON** - VSCode JSON features
- **SQL** - SQL formatter
- **Shell Scripts** - Shell-format extension
- **C/C++** - CMake integration
- **Web Development** - HTML formatting with indentation
- **Version Control** - Git integration

## Keyboard Shortcuts

Common shortcuts enabled in this workspace:

- **Ctrl+Shift+P** (Windows/Linux) / **Cmd+Shift+P** (Mac) - Open Command Palette
- **Ctrl+`** - Toggle Terminal
- **Alt+Shift+F** - Format Document
- **Ctrl+S** - Save with auto-formatting

## Auto-Approve Configuration

The workspace is configured with auto-approval enabled for safe operations:

```json
{
  "claude.autoApproveCommands": true,
  "claude.requireConfirmation": false,
  "claude.interactiveMode": false,
  "claude.autoApprove": {
    "bashCommands": true,
    "fileOperations": true,
    "toolUse": true
  }
}
```

⚠️ **Security Note:** Auto-approval is configured for development workflows. Adjust settings in `.claude/settings.local.json` if you want stricter permission controls.

## Usage Examples

### 1. Code Generation with Claude

```
Ask Claude in the Chat panel:
"Generate a Python function to calculate Fibonacci sequence"
```

### 2. Web Search Integration

```
"Find the latest Node.js best practices"
(Claude will search the web and provide current information)
```

### 3. Git Operations

```
Ask Claude: "Show me the git commit history for this project"
(Respects allowed permissions in settings.local.json)
```

## Tips & Best Practices

1. **Before Customizing:** Review the current settings in `.vscode/settings.json`
2. **Permissions:** Only add necessary permissions to `.claude/settings.local.json`
3. **Format on Save:** Currently enabled - disable if you prefer manual formatting
4. **Version Control:** Commit your `.vscode` and `.claude` folders to share workspace setup with team members
5. **Extensions:** Keep VS Code extensions updated for best performance

## Troubleshooting

### Claude Settings Not Applied

- Reload VS Code: `Ctrl+Shift+P` → "Developer: Reload Window"
- Check `.vscode/settings.json` for syntax errors
- Verify Claude extension is installed and enabled

### Auto-Approve Not Working

- Ensure `claudeCode.initialPermissionMode` is set to `"acceptEdits"`
- Check `.claude/settings.local.json` permissions whitelist
- Review VS Code output logs: `Ctrl+Shift+P` → "Developer: Show Logs"

### Formatting Issues

- Run `Ctrl+Alt+F` to format current file
- Ensure correct formatter is set for file type
- Check formatter extension is installed

## Customization

### Adding Language Support

Edit `.vscode/settings.json` and add formatter configuration:

```json
"[newlanguage]": {
  "editor.defaultFormatter": "extension.id",
  "editor.formatOnSave": true
}
```

### Adjusting Permissions

Edit `.claude/settings.local.json` to allow/restrict operations:

```json
{
  "permissions": {
    "allow": ["Bash(your-safe-command)"],
    "deny": ["Bash(sudo|rm -rf)"]
  }
}
```

## Contributing

To improve this workspace configuration:

1. Test settings changes locally
2. Document any new configurations
3. Update this README with new features
4. Commit changes with descriptive messages

## Resources

- [VS Code Documentation](https://code.visualstudio.com/docs)
- [Claude Code Extension Guide](https://github.com/features/copilot)
- [Prettier Documentation](https://prettier.io)
- [Git Documentation](https://git-scm.com/doc)

## License

This project configuration is provided as-is for development purposes.

## Support

For issues or questions:

- Check this README's Troubleshooting section
- Review VS Code logs: `Ctrl+Shift+P` → "Developer: Show Logs"
- Check extension marketplace for latest versions

---

**Last Updated:** January 2026  
**Workspace Location:** `/root/ws/Everything-portal`
