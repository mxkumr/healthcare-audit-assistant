const { ChatOpenAI } = require('@sap-ai-sdk/langchain');
const { agentToolBeltDefinitions } = require('./agent-tools');
const cds = require('@sap/cds');

class AuditAgentOrchestrator {
    constructor() {
        // Instantiate the model and bind our custom tool-belt signatures right into its call cycle
        this.model = new ChatOpenAI({
            deploymentName: 'gpt-4o' 
        }).bindTools(agentToolBeltDefinitions);
    }

    /**
     * Executes advanced audit analysis. If the prompt requires metrics, 
     * the model will return a structured tool request instead of simple text.
     */
    async executeAuditReview(userQuery) {
        const systemPrompt = `You are an expert autonomous medical auditor evaluating US Medicare claims datasets.
        Your objective is to investigate financial anomalies, billing inflation, and provider outliers.
        You have direct access to automated database tools to pull metrics. If a query requires localized stats, 
        you MUST use the appropriate tool before making a final diagnostic summary.`;

        try {
            const response = await this.model.invoke([
                { role: 'system', content: systemPrompt },
                { role: 'user', content: userQuery }
            ]);

            // If the model decides it needs data, tool_calls will be populated with JSON instructions
            if (response.tool_calls && response.tool_calls.length > 0) {
                return {
                    status: "TOOL_REQUESTED",
                    reasoning: "The AI agent has determined it requires backend database data to fulfill the query.",
                    toolCalls: response.tool_calls
                };
            }

            return {
                status: "TEXT_RESPONSE",
                content: response.content
            };
        } catch (error) {
            console.error("SAP AI Core Model Execution Failure:", error);
            throw error;
        }
    }
}

module.exports = AuditAgentOrchestrator;