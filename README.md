# 🤖 AI-OS Client Setup

Welcome to AI-OS! This repository contains everything you need to connect to the AI-OS system using Claude Code or Windsurf.

## 🎯 What is AI-OS?

AI-OS is a distributed AI collaboration system that enables multiple users to work together using AI agents through MCP (Model Context Protocol) servers. This client repository helps you connect to the AI-OS infrastructure seamlessly.

## 🚀 Quick Start (5 minutes)

### Prerequisites
- **Claude Code** or **Windsurf** IDE installed
- **SSH access** to AI-OS server (provided by your administrator)
- **Git** installed
- **Node.js 18+** (optional, for testing)

### Setup Steps

1. **Clone this repository**
   ```bash
   git clone https://github.com/Pedrovaleriolopez/ai-os-client.git
   cd ai-os-client
   ```

2. **Run the setup script**
   
   **🪟 Windows (PowerShell as Admin):**
   ```powershell
   .\scripts\setup-client.ps1
   ```
   
   **🐧 Linux/Mac:**
   ```bash
   chmod +x scripts/setup-client.sh
   ./scripts/setup-client.sh
   ```

3. **Provide your information when prompted:**
   - Your email
   - User ID (auto-suggested)
   - Server IP (provided by administrator)
   - Tenant ID (default: "default")

4. **Open in your IDE**
   ```bash
   # For Claude Code
   claude .
   
   # For Windsurf
   windsurf .
   ```

## 🧪 Testing Your Connection

After setup, test your MCP connections:

```bash
node test-mcps.js
```

You should see:
```
🧪 Testing MCPs do AI-OS...

1. Testing Orchestrator...
✅ Orchestrator: 4 workflows available

2. Testing Memory Hub...
✅ Memory Hub: Working

3. Testing Context Manager...
✅ Context Manager: Working

4. Testing Document Graph...
✅ Document Graph: Working

✅ Test completed!
```

## 📚 Documentation

- [📖 Complete Setup Guide](docs/CLIENT_SETUP_GUIDE.md) - Detailed setup instructions
- [🤝 Collaboration Guide](docs/COLLABORATION_GUIDE.md) - How to collaborate with your team
- [🔧 MCP Usage Examples](docs/examples/) - Code examples for all MCPs
- [❓ Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions

## 🛠️ Available MCP Servers

### 1. **AI-OS Orchestrator**
Manages workflows and coordinates between different AI agents.

### 2. **Global Memory Hub**
Persistent storage for shared knowledge and data.

### 3. **Context Manager**
Analyzes and manages project context and dependencies.

### 4. **Document Graph**
Neo4j-based graph database for document relationships.

## 💡 Example Usage

### Store data in Memory Hub
```javascript
await memory.store("project-x", {
  name: "New AI Feature",
  status: "in-development",
  team: ["Alice", "Bob"]
});
```

### Execute a workflow
```javascript
const result = await orchestrator.executeWorkflow("data-analysis", {
  dataset: "sales-2024",
  metrics: ["revenue", "growth"]
});
```

### Query Document Graph
```javascript
const docs = await graph.query(
  "MATCH (d:Document) WHERE d.type = 'specification' RETURN d"
);
```

## 🔒 Security

- All connections use SSH tunneling
- User authentication via environment variables
- Tenant isolation for multi-tenant deployments
- No sensitive data stored in this repository

## 🆘 Support

- **Discord**: [AI-OS Community](https://discord.gg/ai-os)
- **Email**: support@allfluence.ai
- **Issues**: [GitHub Issues](https://github.com/Pedrovaleriolopez/ai-os-client/issues)

## 📝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Version**: 1.0.0 | **Last Updated**: January 2025