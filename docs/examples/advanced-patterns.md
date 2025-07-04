# Advanced Agent Patterns

This guide demonstrates advanced patterns and techniques for building sophisticated AI agents in AI-OS.

## 📋 Table of Contents

1. [Multi-Agent Orchestration](#multi-agent-orchestration)
2. [Stateful Conversation Agents](#stateful-conversation-agents)
3. [Streaming and Real-time Agents](#streaming-and-real-time-agents)
4. [Self-Improving Agents](#self-improving-agents)
5. [Distributed Agent Networks](#distributed-agent-networks)

## 🤝 Multi-Agent Orchestration

### Hierarchical Agent System

```typescript
// research-orchestrator.ts
import { Agent, AgentManager } from '@ai-os/agent-framework';
import { z } from 'zod';

export class ResearchOrchestrator extends Agent {
  private subAgents: Map<string, Agent> = new Map();

  async initialize() {
    // Create specialized sub-agents
    this.subAgents.set('data-collector', await this.createSubAgent({
      type: 'web-scraper',
      config: { 
        sources: ['academic', 'news', 'social'],
        rateLimit: 10 
      }
    }));

    this.subAgents.set('analyzer', await this.createSubAgent({
      type: 'data-analyzer',
      config: { 
        models: ['sentiment', 'entity', 'summary'],
        batchSize: 100 
      }
    }));

    this.subAgents.set('report-writer', await this.createSubAgent({
      type: 'document-generator',
      config: { 
        format: 'markdown',
        style: 'academic' 
      }
    }));

    this.logger.info('Research orchestrator initialized with sub-agents');
  }

  async execute(input: { topic: string; depth: string }) {
    try {
      // Phase 1: Data Collection
      const collectionTasks = this.createCollectionTasks(input.topic);
      const rawData = await this.executeParallel(collectionTasks);

      // Phase 2: Analysis
      const analysisResults = await this.analyzeData(rawData);

      // Phase 3: Synthesis
      const report = await this.synthesizeReport(analysisResults, input);

      // Phase 4: Quality Check
      const finalReport = await this.qualityCheck(report);

      return {
        report: finalReport,
        metadata: {
          sources: rawData.length,
          confidence: this.calculateConfidence(analysisResults),
          processingTime: Date.now() - this.startTime
        }
      };
    } catch (error) {
      return await this.handleError(error, input);
    }
  }

  private createCollectionTasks(topic: string) {
    const queries = this.generateSearchQueries(topic);
    
    return queries.map(query => ({
      agent: 'data-collector',
      input: { 
        query,
        maxResults: 20,
        filters: this.getRelevanceFilters(topic)
      },
      timeout: 30000,
      retries: 2
    }));
  }

  private async executeParallel(tasks: any[]) {
    const results = await Promise.allSettled(
      tasks.map(task => 
        this.subAgents.get(task.agent)!.execute(task.input)
      )
    );

    // Handle partial failures
    const successful = results
      .filter(r => r.status === 'fulfilled')
      .map(r => (r as PromiseFulfilledResult<any>).value);

    const failed = results
      .filter(r => r.status === 'rejected')
      .map(r => (r as PromiseRejectedResult).reason);

    if (failed.length > 0) {
      this.logger.warn(`${failed.length} tasks failed`, failed);
    }

    return successful.flat();
  }

  private async analyzeData(data: any[]) {
    // Chunk data for efficient processing
    const chunks = this.chunkArray(data, 50);
    
    const analyses = await Promise.all(
      chunks.map(chunk => 
        this.subAgents.get('analyzer')!.execute({
          data: chunk,
          analyses: ['trends', 'correlations', 'anomalies']
        })
      )
    );

    return this.mergeAnalyses(analyses);
  }

  private async synthesizeReport(analysis: any, input: any) {
    return await this.subAgents.get('report-writer')!.execute({
      title: `Research Report: ${input.topic}`,
      sections: this.generateReportStructure(input.depth),
      data: analysis,
      citations: this.extractCitations(analysis),
      appendices: this.generateAppendices(analysis)
    });
  }

  private async qualityCheck(report: any) {
    const checks = await Promise.all([
      this.checkFactualAccuracy(report),
      this.checkCoherence(report),
      this.checkCompleteness(report),
      this.checkCitations(report)
    ]);

    const issues = checks.filter(c => !c.passed);
    
    if (issues.length > 0) {
      return await this.improveReport(report, issues);
    }

    return report;
  }
}
```

### Agent Communication Protocol

```typescript
// agent-communication.ts
export class AgentCommunicationBus {
  private subscribers: Map<string, Set<Agent>> = new Map();
  private messageQueue: PriorityQueue<Message> = new PriorityQueue();

  subscribe(channel: string, agent: Agent) {
    if (!this.subscribers.has(channel)) {
      this.subscribers.set(channel, new Set());
    }
    this.subscribers.get(channel)!.add(agent);
  }

  async broadcast(message: Message) {
    const subscribers = this.subscribers.get(message.channel) || new Set();
    
    const deliveries = Array.from(subscribers).map(agent => 
      this.deliverMessage(agent, message)
    );

    const results = await Promise.allSettled(deliveries);
    
    return {
      delivered: results.filter(r => r.status === 'fulfilled').length,
      failed: results.filter(r => r.status === 'rejected').length
    };
  }

  private async deliverMessage(agent: Agent, message: Message) {
    try {
      await agent.receiveMessage(message);
      this.recordDelivery(agent.id, message);
    } catch (error) {
      this.handleDeliveryFailure(agent, message, error);
      throw error;
    }
  }
}

// Usage in agents
class CollaborativeAgent extends Agent {
  private bus: AgentCommunicationBus;

  async initialize() {
    this.bus = this.context.communicationBus;
    
    // Subscribe to relevant channels
    this.bus.subscribe('research.data', this);
    this.bus.subscribe('analysis.complete', this);
  }

  async receiveMessage(message: Message) {
    switch (message.type) {
      case 'data.available':
        await this.processNewData(message.payload);
        break;
      
      case 'help.requested':
        await this.provideAssistance(message.payload);
        break;
        
      case 'consensus.needed':
        await this.participateInConsensus(message.payload);
        break;
    }
  }

  async execute(input: any) {
    // Perform work
    const result = await this.doWork(input);
    
    // Notify others
    await this.bus.broadcast({
      channel: 'analysis.complete',
      type: 'result.available',
      payload: {
        agentId: this.id,
        result: result,
        timestamp: Date.now()
      }
    });

    return result;
  }
}
```

## 💭 Stateful Conversation Agents

### Conversation Memory Management

```typescript
// conversation-agent.ts
export class ConversationalAgent extends Agent {
  private conversationStore: ConversationStore;
  private memoryWindow: number = 10; // Keep last 10 exchanges

  async initialize() {
    this.conversationStore = new ConversationStore({
      backend: 'redis',
      ttl: 3600 * 24 // 24 hours
    });
  }

  async execute(input: { 
    message: string; 
    conversationId: string;
    userId: string;
  }) {
    // Load conversation history
    const history = await this.loadConversationHistory(
      input.conversationId,
      input.userId
    );

    // Extract context from history
    const context = this.extractContext(history);
    
    // Detect intent and entities
    const understanding = await this.understandMessage(
      input.message,
      context
    );

    // Generate response based on context
    const response = await this.generateContextualResponse(
      understanding,
      context,
      history
    );

    // Update conversation state
    await this.updateConversation(
      input.conversationId,
      input.userId,
      input.message,
      response
    );

    return {
      response: response.text,
      suggestions: response.suggestions,
      context: {
        intent: understanding.intent,
        sentiment: understanding.sentiment,
        continuity: this.assessContinuity(history)
      }
    };
  }

  private async loadConversationHistory(
    conversationId: string,
    userId: string
  ): Promise<ConversationHistory> {
    const key = `conv:${conversationId}:${userId}`;
    const data = await this.conversationStore.get(key);
    
    if (!data) {
      return this.createNewConversation(conversationId, userId);
    }

    return {
      ...data,
      messages: data.messages.slice(-this.memoryWindow)
    };
  }

  private extractContext(history: ConversationHistory): Context {
    const recentMessages = history.messages.slice(-5);
    
    return {
      topics: this.extractTopics(recentMessages),
      entities: this.mergeEntities(recentMessages),
      userPreferences: history.userProfile?.preferences || {},
      conversationFlow: this.analyzeFlow(recentMessages),
      emotionalTone: this.assessEmotionalTone(recentMessages)
    };
  }

  private async generateContextualResponse(
    understanding: Understanding,
    context: Context,
    history: ConversationHistory
  ) {
    // Build conversation-aware prompt
    const prompt = this.buildContextualPrompt(
      understanding,
      context,
      history
    );

    // Generate with appropriate personality
    const personality = this.selectPersonality(context);
    
    const response = await this.llm.generate({
      prompt,
      systemPrompt: this.getPersonalityPrompt(personality),
      temperature: this.getTemperature(context),
      maxTokens: 500
    });

    // Extract suggestions for next turns
    const suggestions = this.generateSuggestions(
      understanding,
      context,
      response
    );

    return {
      text: response,
      suggestions,
      metadata: {
        personality,
        confidence: understanding.confidence
      }
    };
  }

  private buildContextualPrompt(
    understanding: Understanding,
    context: Context,
    history: ConversationHistory
  ): string {
    let prompt = `Current conversation context:\n`;
    
    // Add recent exchanges
    const recent = history.messages.slice(-3);
    recent.forEach(msg => {
      prompt += `${msg.role}: ${msg.content}\n`;
    });

    // Add current understanding
    prompt += `\nUser intent: ${understanding.intent}\n`;
    prompt += `Key entities: ${understanding.entities.join(', ')}\n`;
    
    // Add context
    prompt += `\nTopics discussed: ${context.topics.join(', ')}\n`;
    prompt += `Conversation flow: ${context.conversationFlow}\n`;
    
    // Add current message
    prompt += `\nUser: ${understanding.message}\n`;
    prompt += `Assistant:`;

    return prompt;
  }
}
```

## 🌊 Streaming and Real-time Agents

### Streaming Response Agent

```typescript
// streaming-agent.ts
export class StreamingAgent extends Agent {
  async *executeStream(
    input: { prompt: string; streamingOptions?: StreamOptions }
  ): AsyncGenerator<StreamChunk, StreamComplete, void> {
    const options = {
      chunkSize: 20, // tokens
      includePartialThoughts: false,
      ...input.streamingOptions
    };

    try {
      // Initialize streaming session
      const session = await this.initializeStream(input.prompt);
      
      // Process in chunks
      let buffer = '';
      let tokenCount = 0;
      let lastYield = Date.now();

      for await (const token of session.tokenStream) {
        buffer += token;
        tokenCount++;

        // Yield based on conditions
        if (this.shouldYield(buffer, tokenCount, lastYield, options)) {
          const chunk = this.prepareChunk(buffer, tokenCount);
          
          yield {
            type: 'partial',
            content: chunk.content,
            metadata: {
              tokens: tokenCount,
              confidence: chunk.confidence,
              timestamp: Date.now()
            }
          };

          buffer = chunk.remainder || '';
          lastYield = Date.now();
        }
      }

      // Yield any remaining content
      if (buffer) {
        yield {
          type: 'partial',
          content: buffer,
          metadata: { tokens: tokenCount, timestamp: Date.now() }
        };
      }

      // Final processing
      const summary = await this.generateSummary(session);
      const metadata = await this.collectMetadata(session);

      // Return completion
      return {
        type: 'complete',
        summary,
        metadata,
        totalTokens: tokenCount,
        duration: Date.now() - session.startTime
      };

    } catch (error) {
      yield {
        type: 'error',
        error: error.message,
        timestamp: Date.now()
      };
      throw error;
    }
  }

  private shouldYield(
    buffer: string,
    tokens: number,
    lastYield: number,
    options: StreamOptions
  ): boolean {
    // Token-based chunking
    if (tokens >= options.chunkSize) return true;
    
    // Time-based chunking (every 100ms)
    if (Date.now() - lastYield > 100) return true;
    
    // Semantic boundaries
    if (this.isSemanticBoundary(buffer)) return true;
    
    return false;
  }

  private isSemanticBoundary(buffer: string): boolean {
    // Check for sentence endings
    const sentenceEndings = /[.!?]\s+[A-Z]/;
    if (sentenceEndings.test(buffer)) return true;
    
    // Check for paragraph breaks
    if (buffer.includes('\n\n')) return true;
    
    // Check for list items
    if (/\n\s*[-*]\s+/.test(buffer)) return true;
    
    return false;
  }
}
```

For full documentation of all patterns, please visit our [documentation site](https://docs.allfluence.ai/agent-framework/patterns).