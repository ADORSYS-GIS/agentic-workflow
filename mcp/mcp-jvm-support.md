# JVM MCP Server Setup

The simplest and most frictionless way to set up the JVM MCP Server is by using `uvx`. This approach automatically handles downloading and running the server in an isolated environment, meaning you don't need to manually clone repositories, create virtual environments, or run pip installs.
https://github.com/xzq-xu/jvm-mcp-server
## Prerequisites

1. **Java Development Kit (JDK 8+)**: Ensure Java is installed and the native tools (`jps`, `jstack`, etc.) are available in your system's PATH.
2. **uv**: The extremely fast Python package manager.
   - Install on Linux/macOS: `curl -LsSf https://astral.sh/uv/install.sh | sh`
   - Install on Windows: `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`

## 1. Local Setup (Simplest)

To configure this for an MCP client like Roo Code, create a `.roo/mcp.json` file in your project directory. 

Using `uvx` means the tool will be fetched and executed on the fly:

```json
{
  "mcpServers": {
    "jvm-mcp-server": {
      "command": "uvx",
      "args": [
        "jvm-mcp-server"
      ]
    }
  }
}
```

## 2. Remote Setup via SSH (Optional)

If you need to monitor a Java application running on a remote server, you can provide the SSH credentials via environment variables directly in your `.roo/mcp.json` configuration:

```json
{
  "mcpServers": {
    "jvm-mcp-server": {
      "command": "uvx",
      "args": [
        "jvm-mcp-server"
      ],
      "env": {
        "SSH_HOST": "user@remote-host",
        "SSH_PORT": "22",
        "SSH_USER": "your-username",
        "SSH_PASSWORD": "your-password"
      }
    }
  }
}
```

## Troubleshooting

The JVM tools need permission to attach to the Java processes you want to monitor. If the MCP server returns errors like `Permission denied` or `Unable to open socket file`:

1. **User Matching**: Ensure the editor/MCP client is running as the **same OS user** that started the Java process.
2. **Docker**: If the Java app is in a Docker container, the container needs sufficient privileges (`--privileged` or sharing `/proc`).
3. **Elevated Privileges**: As a last resort, you can run your editor or MCP client with elevated privileges (sudo/Administrator), though this is generally not recommended for daily development.
