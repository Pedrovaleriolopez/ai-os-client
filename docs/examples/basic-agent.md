# Basic Agent Example

This example demonstrates how to create a simple AI agent that can answer questions using web search.

## 🎯 Overview

We'll build a Question-Answer agent that:
- Accepts natural language questions
- Searches the web for relevant information
- Provides concise, accurate answers
- Includes source citations

## 📝 Complete Code

```typescript
// question-answer-agent.ts
import { Agent, AgentConfig } from '@ai-os/agent-framework';
import { z } from 'zod';

// Define configuration schema
const QAAgentConfigSchema = z.object({
  searchEngine: z.enum(['perplexity', 'exa', 'google']).default('perplexity'),
  apiKey: z.string(),
  maxResults: z.number().min(1).max(20).default(5),
  answerStyle: z.enum(['concise', 'detailed', 'academic']).default('concise'),
  includeSources: z.boolean().default(true)
});

type QAAgentConfig = z.infer<typeof QAAgentConfigSchema>;

// Define input/output schemas
const QAInputSchema = z.object({
  question: z.string().min(1),
  context: z.string().optional(),
  language: z.string().default('en')
});

const QAOutputSchema = z.object({
  answer: z.string(),
  confidence: z.number().min(0).max(1),
  sources: z.array(z.object({
    title: z.string(),
    url: z.string().url(),
    snippet: z.string()
  })),
  relatedQuestions: z.array(z.string()).optional()
});

// Agent implementation
export class QuestionAnswerAgent extends Agent<QAAgentConfig> {
  constructor(config: QAAgentConfig) {
    super(config);
    this.validateConfig();
  }

  private validateConfig() {
    QAAgentConfigSchema.parse(this.config);
  }

  async initialize(): Promise<void> {
    // Initialize required MCP tools
    await this.initializeTools(['web-search', 'text-summarizer']);
    
    this.logger.info('Question-Answer agent initialized', {
      searchEngine: this.config.searchEngine,
      maxResults: this.config.maxResults
    });
  }

  async execute(input: unknown): Promise<z.infer<typeof QAOutputSchema>> {
    // Validate input
    const validInput = QAInputSchema.parse(input);
    
    try {
      // Step 1: Search for information
      const searchResults = await this.searchWeb(validInput.question);
      
      // Step 2: Extract relevant content
      const relevantContent = await this.extractRelevantContent(
        searchResults, 
        validInput.question
      );
      
      // Step 3: Generate answer
      const answer = await this.generateAnswer(
        validInput.question,
        relevantContent,
        validInput.context
      );
      
      // Step 4: Calculate confidence
      const confidence = this.calculateConfidence(searchResults, answer);
      
      // Step 5: Format output
      return {
        answer: answer.text,
        confidence,
        sources: this.config.includeSources ? answer.sources : [],
        relatedQuestions: answer.relatedQuestions
      };
    } catch (error) {
      this.logger.error('Failed to answer question', error);
      throw error;
    }
  }

  private async searchWeb(question: string) {
    const results = await this.tools.use('web-search', {
      query: question,
      engine: this.config.searchEngine,
      limit: this.config.maxResults,
      options: {
        recency: this.detectRecencyRequirement(question),
        scholarly: this.config.answerStyle === 'academic'
      }
    });

    return results;
  }

  private async extractRelevantContent(searchResults: any[], question: string) {
    const contents = await Promise.all(
      searchResults.map(async (result) => {
        const summary = await this.tools.use('text-summarizer', {
          text: result.content,
          maxLength: 200,
          focusOn: question
        });
        
        return {
          source: result,
          summary: summary.text,
          relevance: summary.relevanceScore
        };
      })
    );

    // Sort by relevance and take top results
    return contents
      .sort((a, b) => b.relevance - a.relevance)
      .slice(0, Math.min(3, contents.length));
  }

  private async generateAnswer(
    question: string, 
    content: any[], 
    context?: string
  ) {
    const prompt = this.buildPrompt(question, content, context);
    
    // Use appropriate style
    const styleInstructions = {
      concise: 'Provide a brief, direct answer in 2-3 sentences.',
      detailed: 'Provide a comprehensive answer with explanations.',
      academic: 'Provide a scholarly answer with technical details.'
    };

    const response = await this.llm.generate({
      prompt,
      systemPrompt: styleInstructions[this.config.answerStyle],
      temperature: 0.3,
      maxTokens: this.config.answerStyle === 'concise' ? 150 : 500
    });

    return this.parseResponse(response, content);
  }

  private buildPrompt(question: string, content: any[], context?: string) {
    let prompt = `Question: ${question}\n\n`;
    
    if (context) {
      prompt += `Context: ${context}\n\n`;
    }
    
    prompt += 'Relevant Information:\n';
    content.forEach((item, index) => {
      prompt += `\n[${index + 1}] ${item.summary}\n`;
      prompt += `Source: ${item.source.title}\n`;
    });
    
    prompt += '\nBased on the above information, please answer the question.';
    
    return prompt;
  }

  private parseResponse(response: string, content: any[]) {
    // Extract answer and map sources
    const lines = response.split('\n');
    const answer = lines[0];
    
    // Extract cited source numbers [1], [2], etc.
    const citedSources = [...response.matchAll(/\[(\d+)\]/g)]
      .map(match => parseInt(match[1]) - 1)
      .filter(idx => idx >= 0 && idx < content.length);

    const sources = citedSources.map(idx => ({
      title: content[idx].source.title,
      url: content[idx].source.url,
      snippet: content[idx].source.snippet
    }));

    // Extract related questions if provided
    const relatedMatch = response.match(/Related questions?:(.*)/is);
    const relatedQuestions = relatedMatch
      ? relatedMatch[1].split('\n').filter(q => q.trim()).map(q => q.trim())
      : undefined;

    return {
      text: answer,
      sources,
      relatedQuestions
    };
  }

  private calculateConfidence(searchResults: any[], answer: any): number {
    // Simple confidence calculation based on:
    // - Number of quality sources
    // - Source agreement
    // - Answer completeness
    
    const hasMultipleSources = searchResults.length >= 3;
    const sourcesAgree = answer.sources.length >= 2;
    const answerLength = answer.text.length;
    
    let confidence = 0.5; // Base confidence
    
    if (hasMultipleSources) confidence += 0.2;
    if (sourcesAgree) confidence += 0.2;
    if (answerLength > 50) confidence += 0.1;
    
    return Math.min(confidence, 0.95); // Cap at 95%
  }

  private detectRecencyRequirement(question: string): string {
    const recencyKeywords = ['latest', 'recent', 'today', 'current', '2025'];
    const hasRecency = recencyKeywords.some(keyword => 
      question.toLowerCase().includes(keyword)
    );
    
    return hasRecency ? 'day' : 'year';
  }

  async terminate(): Promise<void> {
    // Cleanup if needed
    await super.terminate();
  }
}
```

## 🚀 Usage Example

```typescript
// main.ts
import { AgentManager } from '@ai-os/agent-framework';
import { QuestionAnswerAgent } from './question-answer-agent';

async function main() {
  // Initialize agent manager
  const manager = new AgentManager();
  
  // Register the agent type
  manager.registerType('qa-agent', QuestionAnswerAgent);
  
  // Create an instance
  const agent = await manager.create({
    name: 'My QA Assistant',
    type: 'qa-agent',
    config: {
      searchEngine: 'perplexity',
      apiKey: process.env.PERPLEXITY_API_KEY,
      maxResults: 10,
      answerStyle: 'detailed',
      includeSources: true
    }
  });

  // Ask a question
  const result = await agent.execute({
    question: 'What are the latest developments in quantum computing?',
    language: 'en'
  });

  console.log('Answer:', result.answer);
  console.log('Confidence:', result.confidence);
  console.log('Sources:', result.sources);
  
  // Cleanup
  await agent.terminate();
}

main().catch(console.error);
```

## 🧪 Testing the Agent

```typescript
// qa-agent.test.ts
import { describe, it, expect } from '@jest/globals';
import { QuestionAnswerAgent } from './question-answer-agent';
import { MockToolRegistry } from '@ai-os/testing';

describe('QuestionAnswerAgent', () => {
  let agent: QuestionAnswerAgent;
  let mockTools: MockToolRegistry;

  beforeEach(async () => {
    mockTools = new MockToolRegistry();
    
    agent = new QuestionAnswerAgent({
      searchEngine: 'perplexity',
      apiKey: 'test-key',
      maxResults: 5,
      answerStyle: 'concise',
      includeSources: true
    });

    agent.tools = mockTools;
    await agent.initialize();
  });

  it('should answer simple questions', async () => {
    // Mock search results
    mockTools.mock('web-search', {
      results: [
        {
          title: 'Quantum Computing Basics',
          url: 'https://example.com/quantum',
          content: 'Quantum computing uses quantum bits...',
          snippet: 'Learn about quantum computing'
        }
      ]
    });

    mockTools.mock('text-summarizer', {
      text: 'Quantum computing uses quantum bits called qubits.',
      relevanceScore: 0.9
    });

    const result = await agent.execute({
      question: 'What is quantum computing?'
    });

    expect(result.answer).toContain('quantum');
    expect(result.confidence).toBeGreaterThan(0.5);
    expect(result.sources).toHaveLength(1);
  });

  it('should handle complex questions with context', async () => {
    const result = await agent.execute({
      question: 'How does this compare to classical computing?',
      context: 'We were discussing quantum computing advantages.'
    });

    expect(result.answer).toBeDefined();
    expect(result.sources.length).toBeGreaterThan(0);
  });
});
```

## 🔧 Configuration Options

### Search Engines

```typescript
// Perplexity - Best for factual questions
{
  searchEngine: 'perplexity',
  apiKey: process.env.PERPLEXITY_API_KEY
}

// Exa - Best for academic/technical questions  
{
  searchEngine: 'exa',
  apiKey: process.env.EXA_API_KEY
}

// Google - Best for general questions
{
  searchEngine: 'google',
  apiKey: process.env.GOOGLE_API_KEY
}
```

### Answer Styles

```typescript
// Concise - Quick, direct answers
{
  answerStyle: 'concise',
  maxResults: 3
}

// Detailed - Comprehensive explanations
{
  answerStyle: 'detailed',
  maxResults: 10
}

// Academic - Scholarly, with citations
{
  answerStyle: 'academic',
  maxResults: 15,
  includeSources: true
}
```

## 📊 Performance Optimization

### Caching

```typescript
class CachedQAAgent extends QuestionAnswerAgent {
  private cache = new Map<string, any>();

  async execute(input: any) {
    const cacheKey = JSON.stringify(input);
    
    // Check cache
    if (this.cache.has(cacheKey)) {
      const cached = this.cache.get(cacheKey);
      if (Date.now() - cached.timestamp < 3600000) { // 1 hour
        return cached.result;
      }
    }

    // Execute normally
    const result = await super.execute(input);
    
    // Cache result
    this.cache.set(cacheKey, {
      result,
      timestamp: Date.now()
    });

    return result;
  }
}
```

### Parallel Processing

```typescript
private async searchWeb(question: string) {
  // Search multiple engines in parallel
  const searches = ['perplexity', 'exa'].map(engine =>
    this.tools.use('web-search', {
      query: question,
      engine,
      limit: 5
    })
  );

  const results = await Promise.all(searches);
  return results.flat();
}
```

## 🚨 Error Handling

```typescript
async execute(input: any) {
  try {
    return await this.performSearch(input);
  } catch (error) {
    if (error.code === 'RATE_LIMIT') {
      // Retry with exponential backoff
      await this.delay(1000);
      return await this.execute(input);
    }
    
    if (error.code === 'NO_RESULTS') {
      // Fallback to broader search
      return await this.broadSearch(input);
    }
    
    // Log and return error response
    this.logger.error('Execution failed', error);
    return {
      answer: 'I apologize, but I was unable to find an answer to your question.',
      confidence: 0,
      sources: [],
      error: error.message
    };
  }
}
```

## 🎯 Best Practices

1. **Always validate inputs** - Use Zod schemas
2. **Include error handling** - Graceful degradation
3. **Log important events** - For debugging
4. **Set reasonable timeouts** - Prevent hanging
5. **Cache when appropriate** - Improve performance
6. **Test edge cases** - Empty results, errors, etc.

## 📚 Next Steps

- Try modifying the agent to support multiple languages
- Add support for follow-up questions
- Implement conversation history
- Create specialized variants (medical, legal, technical)
- Add support for multimodal inputs (images, PDFs)

---

For more examples, see:
- [Advanced Agent Patterns](./advanced-patterns.md)
- [Multi-Agent Systems](./multi-agent-systems.md)
- [Production Deployment](./production-agent.md)