// Test script to validate MCP connections
console.log("🧪 Testing MCPs do AI-OS...\n");

async function testMCPs() {
    console.log("1. Testing Orchestrator...");
    try {
        const workflows = await orchestrator.listWorkflows();
        console.log("✅ Orchestrator: " + workflows.length + " workflows available");
    } catch (e) {
        console.log("❌ Orchestrator: " + e.message);
    }

    console.log("\n2. Testing Memory Hub...");
    try {
        const testKey = "test-" + Date.now();
        await memory.store(testKey, { test: true, user: process.env.USER_ID });
        const data = await memory.retrieve(testKey);
        console.log("✅ Memory Hub: Working");
        await memory.delete(testKey);
    } catch (e) {
        console.log("❌ Memory Hub: " + e.message);
    }

    console.log("\n3. Testing Context Manager...");
    try {
        const structure = await context.getProjectStructure();
        console.log("✅ Context Manager: Working");
    } catch (e) {
        console.log("❌ Context Manager: " + e.message);
    }

    console.log("\n4. Testing Document Graph...");
    try {
        const result = await graph.query("MATCH (n) RETURN count(n) as count LIMIT 1");
        console.log("✅ Document Graph: Working");
    } catch (e) {
        console.log("❌ Document Graph: " + e.message);
    }
}

// Run tests
testMCPs().then(() => {
    console.log("\n✅ Test completed!");
}).catch(console.error);