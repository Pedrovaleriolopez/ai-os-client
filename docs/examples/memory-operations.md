# Memory Hub Operations

## Basic Operations

### Store Data
```javascript
await memory.store("project-x", {
  name: "AI Assistant",
  description: "Multi-modal AI system",
  team: ["Alice", "Bob", "Charlie"],
  status: "in-development"
});
```

### Retrieve Data
```javascript
const project = await memory.retrieve("project-x");
console.log(project);
```

### Search Data
```javascript
const results = await memory.search("AI");
console.log(`Found ${results.length} matches`);
```

### Delete Data
```javascript
await memory.delete("project-x");
```

## Advanced Examples

### Batch Operations
```javascript
// Store multiple items
const items = [
  { key: "config-dev", value: { env: "development", debug: true } },
  { key: "config-prod", value: { env: "production", debug: false } }
];

for (const item of items) {
  await memory.store(item.key, item.value);
}
```

### Metadata Storage
```javascript
await memory.store("document-123", {
  content: "Technical specification...",
  metadata: {
    author: process.env.USER_ID,
    created: new Date(),
    tags: ["technical", "specification", "v2"]
  }
});
```