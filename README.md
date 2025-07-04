# 🤖 AI-OS Client Setup

Welcome to AI-OS! This repository contains everything you need to:
- 🔌 **Connect** to the AI-OS system using Claude Code or Windsurf
- 🤖 **Create** custom AI agents using the Agent Framework
- 🚀 **Deploy** your agents to the AI-OS ecosystem

## 🚀 Quick Start

### Prerequisites
- Claude Code or Windsurf installed
- Git installed
- Node.js 18+ (for agent development)

### Setup (5 minutes)

1. **Clone this repository**
   ```bash
   git clone https://github.com/allfluencee/ai-os-client.git
   cd ai-os-client
   ```

2. **Register or login (first time only)**
   
   **Windows:**
   ```powershell
   ./scripts/register-user.ps1
   ```
   
   **Mac/Linux:**
   ```bash
   chmod +x scripts/register-user.sh
   ./scripts/register-user.sh
   ```

3. **Run setup script**
   
   **Windows:**
   ```powershell
   ./scripts/setup-client.ps1
   ```
   
   **Mac/Linux:**
   ```bash
   chmod +x scripts/setup-client.sh
   ./scripts/setup-client.sh
   ```

4. **Open in your IDE**
   ```bash
   claude .    # For Claude Code
   windsurf .  # For Windsurf
   ```

## 📚 Documentation

- [Complete Setup Guide](docs/CLIENT_SETUP_GUIDE.md)
- [Agent Development Guide](docs/AGENT_DEVELOPMENT_GUIDE.md) 🆕
- [Quick Collaboration Guide](.github/README_COLLABORATION.md)
- [MCP Examples](docs/examples/)

## 🤖 Creating AI Agents

### Quick Agent Example
```typescript
import { Agent } from '@ai-os/agent-framework';

export class MyAgent extends Agent {
  async execute(input: any) {
    // Use MCP tools
    const data = await this.memory.retrieve('context');
    
    // Process with LLM
    const result = await this.llm.generate({
      prompt: `Process: ${input.text}`,
      context: data
    });
    
    return result;
  }
}
```

[📖 Full Agent Development Guide](docs/AGENT_DEVELOPMENT_GUIDE.md)

## 🧪 Testing

After setup, test your connection:
```javascript
node test-mcps.js
```

## 🆘 Support

- **Discord**: [AI-OS Community](https://discord.gg/ai-os)
- **Email**: support@allfluence.ai
- **Issues**: [GitHub Issues](https://github.com/allfluencee/ai-os-client/issues)

## 📄 License

This project is licensed under the MIT License.