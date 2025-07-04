# Integration Examples

This guide demonstrates how to integrate AI-OS with popular platforms and services, including ClickUp, Slack, GitHub, and more.

## 📋 Table of Contents

1. [ClickUp Task Automation](#clickup-task-automation)
2. [Slack Bot Integration](#slack-bot-integration)
3. [GitHub Workflow Automation](#github-workflow-automation)
4. [Email Processing Pipeline](#email-processing-pipeline)
5. [Database Sync Agent](#database-sync-agent)
6. [API Gateway Integration](#api-gateway-integration)

## 📌 ClickUp Task Automation

### Automated Task Management Agent

```typescript
// clickup-automation-agent.ts
import { Agent } from '@ai-os/agent-framework';
import { ClickUpClient } from '@ai-os/clickup-integration';
import { z } from 'zod';

export class ClickUpAutomationAgent extends Agent {
  private clickup: ClickUpClient;
  private automationRules: Map<string, AutomationRule> = new Map();

  async initialize() {
    this.clickup = new ClickUpClient({
      apiKey: this.config.clickupApiKey
    });

    // Load automation rules
    await this.loadAutomationRules();

    // Set up webhook listener
    await this.setupWebhookListener();
  }

  private async setupWebhookListener() {
    // Subscribe to ClickUp events
    const events = [
      'taskCreated',
      'taskUpdated', 
      'taskStatusUpdated',
      'commentPosted'
    ];

    for (const event of events) {
      this.on(`clickup:${event}`, async (data) => {
        await this.handleClickUpEvent(event, data);
      });
    }
  }

  async handleClickUpEvent(event: string, data: any) {
    try {
      // Check if this is an agent task
      if (!this.isAgentTask(data.task)) {
        return;
      }

      // Find matching automation rules
      const rules = this.findMatchingRules(event, data);

      // Execute rules in priority order
      for (const rule of rules) {
        await this.executeRule(rule, data);
      }
    } catch (error) {
      this.logger.error('Failed to handle ClickUp event', {
        event,
        error: error.message
      });
    }
  }

  private async executeRule(rule: AutomationRule, data: any) {
    switch (rule.action) {
      case 'auto-assign':
        await this.autoAssignTask(data.task, rule.params);
        break;
        
      case 'create-subtasks':
        await this.createSubtasks(data.task, rule.params);
        break;
        
      case 'execute-agent':
        await this.executeAgentTask(data.task, rule.params);
        break;
        
      case 'update-fields':
        await this.updateCustomFields(data.task, rule.params);
        break;
    }
  }

  private async autoAssignTask(task: any, params: any) {
    // Analyze task to determine best assignee
    const analysis = await this.analyzeTask(task);
    
    // Find best agent based on:
    // - Current workload
    // - Skill match
    // - Availability
    const bestAgent = await this.findBestAgent(analysis);

    // Update task assignment
    await this.clickup.updateTask(task.id, {
      assignees: [bestAgent.clickupUserId],
      customFields: {
        agentId: bestAgent.id,
        estimatedDuration: analysis.estimatedDuration
      }
    });

    // Notify agent
    await this.notifyAgent(bestAgent, task);
  }

  private async createSubtasks(task: any, params: any) {
    // Analyze task complexity
    const breakdown = await this.analyzeTaskBreakdown(task);

    // Create subtasks
    const subtasks = [];
    for (const subtask of breakdown.subtasks) {
      const created = await this.clickup.createTask(task.listId, {
        name: subtask.name,
        description: subtask.description,
        parent: task.id,
        priority: subtask.priority,
        customFields: {
          agentType: subtask.agentType,
          automationGenerated: true
        }
      });
      subtasks.push(created);
    }

    // Update parent task
    await this.clickup.addComment(task.id, 
      `Created ${subtasks.length} subtasks automatically:\n` +
      subtasks.map(t => `- ${t.name}`).join('\n')
    );
  }

  private async executeAgentTask(task: any, params: any) {
    const { agentType, agentConfig } = task.customFields;

    // Create execution request
    const execution = await this.orchestrator.execute({
      agentType,
      config: agentConfig,
      input: {
        taskDescription: task.description,
        attachments: await this.fetchAttachments(task),
        context: await this.gatherContext(task)
      }
    });

    // Update task status
    await this.clickup.updateTask(task.id, {
      status: 'In Progress',
      customFields: {
        executionId: execution.id,
        executionStatus: 'running'
      }
    });

    // Monitor execution
    execution.on('progress', async (progress) => {
      await this.updateTaskProgress(task, progress);
    });

    execution.on('complete', async (result) => {
      await this.handleExecutionComplete(task, result);
    });
  }
}

// Example automation rules
const automationRules = [
  {
    name: 'Auto-assign research tasks',
    trigger: {
      event: 'taskCreated',
      conditions: [
        { field: 'tags', operator: 'contains', value: 'research' }
      ]
    },
    action: 'auto-assign',
    params: {
      agentType: 'research',
      priorityBoost: 1
    },
    priority: 100
  },
  {
    name: 'Break down complex tasks',
    trigger: {
      event: 'taskCreated',
      conditions: [
        { field: 'estimatedTime', operator: '>', value: 8 * 60 * 60 * 1000 }
      ]
    },
    action: 'create-subtasks',
    params: {
      maxSubtasks: 5,
      autoAssign: true
    },
    priority: 90
  },
  {
    name: 'Execute on status change',
    trigger: {
      event: 'taskStatusUpdated',
      conditions: [
        { field: 'newStatus', operator: '=', value: 'Ready to Execute' }
      ]
    },
    action: 'execute-agent',
    params: {
      notifyOnComplete: true
    },
    priority: 100
  }
];
```

### ClickUp Sprint Management

```typescript
// sprint-management-agent.ts
export class SprintManagementAgent extends Agent {
  async analyzeSprint(sprintId: string) {
    // Get all tasks in sprint
    const tasks = await this.clickup.getTasks({
      listId: sprintId,
      includeSubtasks: true,
      customFields: true
    });

    // Analyze sprint health
    const analysis = {
      totalTasks: tasks.length,
      byStatus: this.groupByStatus(tasks),
      byPriority: this.groupByPriority(tasks),
      velocity: await this.calculateVelocity(tasks),
      risks: await this.identifyRisks(tasks),
      recommendations: []
    };

    // Generate recommendations
    if (analysis.risks.length > 0) {
      analysis.recommendations = await this.generateRecommendations(
        analysis
      );
    }

    // Create sprint report
    const report = await this.generateSprintReport(analysis);

    // Post to ClickUp
    await this.clickup.createDoc({
      name: `Sprint Analysis - ${new Date().toISOString()}`,
      content: report,
      folder: this.config.reportsFolderId
    });

    return analysis;
  }

  private async identifyRisks(tasks: any[]): Promise<Risk[]> {
    const risks: Risk[] = [];

    // Check for blockers
    const blocked = tasks.filter(t => t.status === 'Blocked');
    if (blocked.length > 0) {
      risks.push({
        type: 'blocked-tasks',
        severity: 'high',
        count: blocked.length,
        tasks: blocked.map(t => t.id),
        message: `${blocked.length} tasks are blocked`
      });
    }

    // Check for overdue tasks
    const overdue = tasks.filter(t => 
      t.dueDate && new Date(t.dueDate) < new Date()
    );
    if (overdue.length > 0) {
      risks.push({
        type: 'overdue-tasks',
        severity: 'medium',
        count: overdue.length,
        tasks: overdue.map(t => t.id),
        message: `${overdue.length} tasks are overdue`
      });
    }

    // Check workload distribution
    const workload = this.analyzeWorkload(tasks);
    if (workload.imbalanced) {
      risks.push({
        type: 'workload-imbalance',
        severity: 'medium',
        details: workload,
        message: 'Workload is not evenly distributed'
      });
    }

    return risks;
  }
}
```

## 💬 Slack Bot Integration

### AI-Powered Slack Assistant

```typescript
// slack-bot-agent.ts
import { Agent } from '@ai-os/agent-framework';
import { App as SlackApp } from '@slack/bolt';

export class SlackBotAgent extends Agent {
  private slack: SlackApp;
  private conversations: Map<string, ConversationContext> = new Map();

  async initialize() {
    this.slack = new SlackApp({
      token: this.config.slackBotToken,
      signingSecret: this.config.slackSigningSecret,
      socketMode: true,
      appToken: this.config.slackAppToken
    });

    // Register event handlers
    this.registerSlackHandlers();

    // Start the app
    await this.slack.start();
    this.logger.info('Slack bot started');
  }

  private registerSlackHandlers() {
    // Handle mentions
    this.slack.event('app_mention', async ({ event, say }) => {
      await this.handleMention(event, say);
    });

    // Handle direct messages
    this.slack.message(async ({ message, say }) => {
      await this.handleDirectMessage(message, say);
    });

    // Handle slash commands
    this.slack.command('/ai', async ({ command, ack, respond }) => {
      await ack();
      await this.handleSlashCommand(command, respond);
    });

    // Handle interactive elements
    this.slack.action('task_action', async ({ action, ack, respond }) => {
      await ack();
      await this.handleInteraction(action, respond);
    });
  }

  private async handleMention(event: any, say: any) {
    const { text, user, channel, thread_ts } = event;
    
    // Extract the actual message (remove mention)
    const message = text.replace(/<@[A-Z0-9]+>/g, '').trim();
    
    // Get or create conversation context
    const context = this.getConversationContext(channel, thread_ts);
    
    // Process the message
    const response = await this.processMessage(message, context, user);
    
    // Send response
    await say({
      text: response.text,
      blocks: response.blocks,
      thread_ts: thread_ts || event.ts
    });
  }

  private async processMessage(
    message: string,
    context: ConversationContext,
    userId: string
  ) {
    // Detect intent
    const intent = await this.detectIntent(message, context);
    
    switch (intent.type) {
      case 'create-task':
        return await this.handleCreateTask(intent, userId);
        
      case 'search-knowledge':
        return await this.handleKnowledgeSearch(intent, context);
        
      case 'summarize-channel':
        return await this.handleChannelSummary(intent, context);
        
      case 'schedule-meeting':
        return await this.handleMeetingSchedule(intent, userId);
        
      default:
        return await this.handleGeneralQuery(message, context);
    }
  }

  private async handleCreateTask(intent: any, userId: string) {
    const { title, description, priority, assignee } = intent.entities;
    
    // Create task in ClickUp
    const task = await this.clickup.createTask({
      name: title,
      description: description || '',
      priority: this.mapPriority(priority),
      assignees: assignee ? [await this.resolveUser(assignee)] : [],
      customFields: {
        createdFrom: 'slack',
        createdBy: userId
      }
    });

    // Return interactive message
    return {
      text: `Task created: ${task.name}`,
      blocks: [
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: `✅ Task created successfully!\n*${task.name}*\n${task.url}`
          }
        },
        {
          type: 'actions',
          elements: [
            {
              type: 'button',
              text: { type: 'plain_text', text: 'View Task' },
              url: task.url,
              action_id: 'view_task'
            },
            {
              type: 'button',
              text: { type: 'plain_text', text: 'Add Details' },
              value: task.id,
              action_id: 'add_details'
            }
          ]
        }
      ]
    };
  }

  private async handleKnowledgeSearch(intent: any, context: any) {
    const { query, filters } = intent.entities;
    
    // Search across multiple sources
    const results = await this.searchKnowledge(query, {
      sources: filters?.sources || ['docs', 'tickets', 'slack'],
      timeRange: filters?.timeRange || '30d',
      relevanceThreshold: 0.7
    });

    // Format results
    const blocks = [
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `*Search Results for:* ${query}`
        }
      },
      { type: 'divider' }
    ];

    for (const result of results.slice(0, 5)) {
      blocks.push({
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `*${result.title}*\n${result.summary}\n` +
                `_Source: ${result.source} | Relevance: ${Math.round(result.relevance * 100)}%_`
        },
        accessory: {
          type: 'button',
          text: { type: 'plain_text', text: 'View' },
          url: result.url
        }
      });
    }

    return { blocks };
  }

  private async handleChannelSummary(intent: any, context: any) {
    const { timeRange = '24h', topics } = intent.entities;
    
    // Fetch channel history
    const history = await this.slack.client.conversations.history({
      channel: context.channelId,
      oldest: this.getTimestamp(timeRange)
    });

    // Analyze messages
    const analysis = await this.analyzeConversation(history.messages, {
      extractTopics: true,
      identifyDecisions: true,
      findActionItems: true,
      summarizeDiscussions: true
    });

    // Generate summary
    const summary = await this.generateSummary(analysis, topics);

    return {
      blocks: [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: `Channel Summary (${timeRange})`
          }
        },
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: summary.overview
          }
        },
        {
          type: 'section',
          fields: [
            {
              type: 'mrkdwn',
              text: `*Key Topics*\n${summary.topics.join('\n• ')}`
            },
            {
              type: 'mrkdwn',
              text: `*Decisions*\n${summary.decisions.join('\n• ')}`
            }
          ]
        },
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: `*Action Items*\n${summary.actionItems.map(
              item => `• ${item.task} - @${item.assignee}`
            ).join('\n')}`
          }
        }
      ]
    };
  }
}

// Scheduled summary agent
export class SlackSummaryAgent extends Agent {
  async generateDailySummary(channelId: string) {
    const summary = await this.createChannelSummary(channelId, '24h');
    
    await this.slack.client.chat.postMessage({
      channel: channelId,
      text: 'Daily Summary',
      blocks: [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: '📊 Daily Channel Summary'
          }
        },
        ...summary.blocks,
        {
          type: 'context',
          elements: [
            {
              type: 'mrkdwn',
              text: `Generated at ${new Date().toLocaleString()}`
            }
          ]
        }
      ]
    });
  }
}
```

## 🐙 GitHub Workflow Automation

### PR Review Agent

```typescript
// github-pr-agent.ts
import { Agent } from '@ai-os/agent-framework';
import { Octokit } from '@octokit/rest';

export class GitHubPRAgent extends Agent {
  private github: Octokit;
  private reviewRules: ReviewRule[] = [];

  async initialize() {
    this.github = new Octokit({
      auth: this.config.githubToken
    });

    // Load review rules
    this.reviewRules = await this.loadReviewRules();

    // Set up webhooks
    await this.setupWebhooks();
  }

  async handlePullRequest(event: any) {
    const { action, pull_request, repository } = event;

    switch (action) {
      case 'opened':
      case 'synchronize':
        await this.reviewPullRequest(pull_request, repository);
        break;
        
      case 'review_requested':
        await this.handleReviewRequest(pull_request, repository);
        break;
    }
  }

  private async reviewPullRequest(pr: any, repo: any) {
    try {
      // Fetch PR details
      const files = await this.github.pulls.listFiles({
        owner: repo.owner.login,
        repo: repo.name,
        pull_number: pr.number
      });

      // Run automated checks
      const checks = await Promise.all([
        this.checkCodeQuality(files.data),
        this.checkSecurity(files.data),
        this.checkTests(pr, repo),
        this.checkDocumentation(files.data),
        this.checkDependencies(files.data)
      ]);

      // Generate review
      const review = this.generateReview(checks);

      // Post review
      await this.postReview(pr, repo, review);

      // Update PR status
      await this.updatePRStatus(pr, repo, review);

    } catch (error) {
      this.logger.error('Failed to review PR', error);
    }
  }

  private async checkCodeQuality(files: any[]): Promise<CheckResult> {
    const issues: Issue[] = [];
    
    for (const file of files) {
      if (this.isCodeFile(file.filename)) {
        // Get file content
        const content = await this.getFileContent(file);
        
        // Run quality checks
        const fileIssues = await this.analyzeCode(content, file.filename);
        
        issues.push(...fileIssues.map(issue => ({
          ...issue,
          file: file.filename,
          line: issue.line
        })));
      }
    }

    return {
      type: 'code-quality',
      passed: issues.filter(i => i.severity === 'error').length === 0,
      issues,
      summary: this.summarizeCodeQuality(issues)
    };
  }

  private async checkSecurity(files: any[]): Promise<CheckResult> {
    const vulnerabilities: Vulnerability[] = [];

    // Check for sensitive data
    for (const file of files) {
      const content = await this.getFileContent(file);
      
      // Check for secrets
      const secrets = await this.detectSecrets(content);
      if (secrets.length > 0) {
        vulnerabilities.push(...secrets.map(s => ({
          type: 'exposed-secret',
          severity: 'critical',
          file: file.filename,
          line: s.line,
          message: `Possible ${s.type} detected`
        })));
      }

      // Check for vulnerabilities
      if (file.filename.endsWith('package.json')) {
        const deps = await this.checkDependencyVulnerabilities(content);
        vulnerabilities.push(...deps);
      }
    }

    return {
      type: 'security',
      passed: vulnerabilities.length === 0,
      issues: vulnerabilities,
      summary: this.summarizeSecurity(vulnerabilities)
    };
  }

  private async postReview(pr: any, repo: any, review: Review) {
    // Create review comment
    const comment = this.formatReviewComment(review);

    await this.github.pulls.createReview({
      owner: repo.owner.login,
      repo: repo.name,
      pull_number: pr.number,
      body: comment.body,
      event: review.approved ? 'APPROVE' : 'REQUEST_CHANGES',
      comments: comment.inlineComments
    });

    // Add labels
    const labels = this.determineLabels(review);
    if (labels.length > 0) {
      await this.github.issues.addLabels({
        owner: repo.owner.login,
        repo: repo.name,
        issue_number: pr.number,
        labels
      });
    }
  }

  private formatReviewComment(review: Review): any {
    const sections = [];

    // Summary
    sections.push(`## 🤖 Automated Review Summary\n`);
    sections.push(review.summary);

    // Checks
    sections.push(`\n## 📋 Checks\n`);
    for (const check of review.checks) {
      const icon = check.passed ? '✅' : '❌';
      sections.push(`${icon} **${check.type}**: ${check.summary}`);
    }

    // Issues
    if (review.issues.length > 0) {
      sections.push(`\n## 🚨 Issues Found\n`);
      
      const criticalIssues = review.issues.filter(i => i.severity === 'critical');
      const errors = review.issues.filter(i => i.severity === 'error');
      const warnings = review.issues.filter(i => i.severity === 'warning');

      if (criticalIssues.length > 0) {
        sections.push(`### Critical (${criticalIssues.length})`);
        criticalIssues.forEach(issue => {
          sections.push(`- **${issue.file}:${issue.line}** - ${issue.message}`);
        });
      }

      if (errors.length > 0) {
        sections.push(`### Errors (${errors.length})`);
        errors.forEach(issue => {
          sections.push(`- **${issue.file}:${issue.line}** - ${issue.message}`);
        });
      }

      if (warnings.length > 0) {
        sections.push(`### Warnings (${warnings.length})`);
        warnings.slice(0, 5).forEach(issue => {
          sections.push(`- **${issue.file}:${issue.line}** - ${issue.message}`);
        });
        if (warnings.length > 5) {
          sections.push(`- ... and ${warnings.length - 5} more warnings`);
        }
      }
    }

    // Suggestions
    if (review.suggestions.length > 0) {
      sections.push(`\n## 💡 Suggestions\n`);
      review.suggestions.forEach(suggestion => {
        sections.push(`- ${suggestion}`);
      });
    }

    // Inline comments
    const inlineComments = review.issues
      .filter(issue => issue.line && issue.suggestion)
      .map(issue => ({
        path: issue.file,
        line: issue.line,
        body: `**${issue.severity}**: ${issue.message}\n\n` +
              `**Suggestion:**\n\`\`\`suggestion\n${issue.suggestion}\n\`\`\``
      }));

    return {
      body: sections.join('\n'),
      inlineComments
    };
  }
}

// CI/CD Integration Agent
export class GitHubCIAgent extends Agent {
  async handleWorkflowRun(event: any) {
    const { action, workflow_run, repository } = event;

    if (action === 'completed' && workflow_run.conclusion === 'failure') {
      await this.analyzeFailure(workflow_run, repository);
    }
  }

  private async analyzeFailure(run: any, repo: any) {
    // Get workflow logs
    const logs = await this.github.actions.downloadWorkflowRunLogs({
      owner: repo.owner.login,
      repo: repo.name,
      run_id: run.id
    });

    // Analyze failure
    const analysis = await this.analyzeWorkflowLogs(logs.data);

    // Generate fix suggestions
    const suggestions = await this.suggestFixes(analysis);

    // Create issue or comment
    if (run.pull_requests.length > 0) {
      // Comment on PR
      await this.commentOnPR(
        run.pull_requests[0],
        repo,
        analysis,
        suggestions
      );
    } else {
      // Create issue
      await this.createFailureIssue(
        repo,
        run,
        analysis,
        suggestions
      );
    }

    // Notify relevant team members
    await this.notifyTeam(run, analysis);
  }
}
```

## 📧 Email Processing Pipeline

### Email Automation Agent

```typescript
// email-processing-agent.ts
import { Agent } from '@ai-os/agent-framework';
import { EmailClient } from './email-client';

export class EmailProcessingAgent extends Agent {
  private emailClient: EmailClient;
  private processingRules: ProcessingRule[] = [];

  async initialize() {
    this.emailClient = new EmailClient({
      provider: this.config.emailProvider,
      credentials: this.config.emailCredentials
    });

    // Load processing rules
    this.processingRules = await this.loadProcessingRules();

    // Start monitoring
    await this.startEmailMonitoring();
  }

  private async startEmailMonitoring() {
    // Set up IMAP IDLE or polling
    this.emailClient.on('new-email', async (email) => {
      await this.processEmail(email);
    });

    await this.emailClient.startMonitoring({
      folders: ['INBOX', 'Support'],
      interval: 60000 // Check every minute
    });
  }

  async processEmail(email: Email) {
    try {
      // Extract metadata
      const metadata = this.extractMetadata(email);
      
      // Classify email
      const classification = await this.classifyEmail(email);
      
      // Find matching rules
      const matchingRules = this.findMatchingRules(
        email,
        classification
      );

      // Execute rules
      for (const rule of matchingRules) {
        await this.executeRule(rule, email, classification);
      }

      // Mark as processed
      await this.emailClient.markAsProcessed(email.id);

    } catch (error) {
      this.logger.error('Failed to process email', {
        emailId: email.id,
        error: error.message
      });
    }
  }

  private async classifyEmail(email: Email): Promise<EmailClassification> {
    // Analyze content
    const analysis = await this.analyzeContent(email);

    return {
      type: this.determineEmailType(analysis),
      priority: this.calculatePriority(email, analysis),
      category: analysis.primaryTopic,
      sentiment: analysis.sentiment,
      intent: analysis.intent,
      entities: analysis.entities,
      requiresResponse: analysis.requiresResponse,
      responseDeadline: this.calculateDeadline(email, analysis)
    };
  }

  private async executeRule(
    rule: ProcessingRule,
    email: Email,
    classification: EmailClassification
  ) {
    switch (rule.action) {
      case 'create-ticket':
        await this.createSupportTicket(email, classification);
        break;
        
      case 'auto-respond':
        await this.sendAutoResponse(email, rule.template);
        break;
        
      case 'forward':
        await this.forwardEmail(email, rule.recipients);
        break;
        
      case 'extract-data':
        await this.extractAndStoreData(email, rule.schema);
        break;
        
      case 'trigger-workflow':
        await this.triggerWorkflow(rule.workflowId, {
          email,
          classification
        });
        break;
    }
  }

  private async createSupportTicket(
    email: Email,
    classification: EmailClassification
  ) {
    // Extract key information
    const ticketData = {