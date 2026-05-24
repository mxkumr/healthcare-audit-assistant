/**
 * Structured tool signatures mapping to Backend's downstream data aggregates.
 * The descriptions must be highly descriptive so the LLM handles function routing accurately.
 */
const agentToolBeltDefinitions = [
    {
        type: "function",
        function: {
            name: "getRegionalBillingOutliers",
            description: "Queries the database for providers whose clinical payment-to-charge ratio exceeds the normal variance threshold within a specific state.",
            parameters: {
                type: "object",
                properties: {
                    state: {
                        type: "string",
                        description: "The two-letter US State abbreviation (e.g., FL, NY, CA) to target the investigation area."
                    }
                },
                required: ["state"]
            }
        }
    },
    {
        type: "function",
        function: {
            name: "getProviderClaimDetails",
            description: "Retrieves granular procedural volumes, total charges, and risk evaluation metadata for a specific National Provider Identifier (NPI).",
            parameters: {
                type: "object",
                properties: {
                    npi: {
                        type: "string",
                        description: "The 10-digit numeric National Provider Identifier unique string identifying the medical facility."
                    }
                },
                required: ["npi"]
            }
        }
    }
];

module.exports = { agentToolBeltDefinitions };