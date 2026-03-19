# Synkra AIOS Development Rules for Claude Code

You are working with Synkra AIOS, an AI-Orchestrated System for Full Stack Development.

## Core Framework Understanding

Synkra AIOS is a meta-framework that orchestrates AI agents to handle complex development workflows. Always recognize and work within this architecture.

## Agent System

### Agent Activation
- Agents are activated with @agent-name syntax: @dev, @qa, @architect, @pm, @po, @sm, @analyst
- The master agent is activated with @aios-master
- Agent commands use the * prefix: *help, *create-story, *task, *exit

### Agent Context
When an agent is active:
- Follow that agent's specific persona and expertise
- Use the agent's designated workflow patterns
- Maintain the agent's perspective throughout the interaction

## Development Methodology

### Story-Driven Development
1. **Work from stories** - All development starts with a story in `docs/stories/`
2. **Update progress** - Mark checkboxes as tasks complete: [ ] → [x]
3. **Track changes** - Maintain the File List section in the story
4. **Follow criteria** - Implement exactly what the acceptance criteria specify

### Code Standards
- Write clean, self-documenting code
- Follow existing patterns in the codebase
- Include comprehensive error handling
- Add unit tests for all new functionality
- Use TypeScript/JavaScript best practices

### Testing Requirements
- Run all tests before marking tasks complete
- Ensure linting passes: `npm run lint`
- Verify type checking: `npm run typecheck`
- Add tests for new features
- Test edge cases and error scenarios

## AIOS Framework Structure

```
aios-core/
├── agents/         # Agent persona definitions (YAML/Markdown)
├── tasks/          # Executable task workflows
├── workflows/      # Multi-step workflow definitions
├── templates/      # Document and code templates
├── checklists/     # Validation and review checklists
└── rules/          # Framework rules and patterns

docs/
├── stories/        # Development stories (numbered)
├── prd/            # Product requirement documents
├── architecture/   # System architecture documentation
└── guides/         # User and developer guides
```

## Workflow Execution

### Task Execution Pattern
1. Read the complete task/workflow definition
2. Understand all elicitation points
3. Execute steps sequentially
4. Handle errors gracefully
5. Provide clear feedback

### Interactive Workflows
- Workflows with `elicit: true` require user input
- Present options clearly
- Validate user responses
- Provide helpful defaults

## Best Practices

### When implementing features:
- Check existing patterns first
- Reuse components and utilities
- Follow naming conventions
- Keep functions focused and testable
- Document complex logic

### When working with agents:
- Respect agent boundaries
- Use appropriate agent for each task
- Follow agent communication patterns
- Maintain agent context

### When handling errors:
```javascript
try {
  // Operation
} catch (error) {
  console.error(`Error in ${operation}:`, error);
  // Provide helpful error message
  throw new Error(`Failed to ${operation}: ${error.message}`);
}
```

## Git & GitHub Integration

### Commit Conventions
- Use conventional commits: `feat:`, `fix:`, `docs:`, `chore:`, etc.
- Reference story ID: `feat: implement IDE detection [Story 2.1]`
- Keep commits atomic and focused

### GitHub CLI Usage
- Ensure authenticated: `gh auth status`
- Use for PR creation: `gh pr create`
- Check org access: `gh api user/memberships`

## AIOS-Specific Patterns

### Working with Templates
```javascript
const template = await loadTemplate('template-name');
const rendered = await renderTemplate(template, context);
```

### Agent Command Handling
```javascript
if (command.startsWith('*')) {
  const agentCommand = command.substring(1);
  await executeAgentCommand(agentCommand, args);
}
```

### Story Updates
```javascript
// Update story progress
const story = await loadStory(storyId);
story.updateTask(taskId, { status: 'completed' });
await story.save();
```

## Environment Setup

### Required Tools
- Node.js 18+ 
- GitHub CLI
- Git
- Your preferred package manager (npm/yarn/pnpm)

### Configuration Files
- `.aios/config.yaml` - Framework configuration
- `.env` - Environment variables
- `aios.config.js` - Project-specific settings

## Common Commands

### AIOS Master Commands
- `*help` - Show available commands
- `*create-story` - Create new story
- `*task {name}` - Execute specific task
- `*workflow {name}` - Run workflow

### Development Commands
- `npm run dev` - Start development
- `npm test` - Run tests
- `npm run lint` - Check code style
- `npm run build` - Build project

## Debugging

### Enable Debug Mode
```bash
export AIOS_DEBUG=true
```

### View Agent Logs
```bash
tail -f .aios/logs/agent.log
```

### Trace Workflow Execution
```bash
npm run trace -- workflow-name
```

## Claude Code Specific Configuration

### Performance Optimization
- Prefer batched tool calls when possible for better performance
- Use parallel execution for independent operations
- Cache frequently accessed data in memory during sessions

### Tool Usage Guidelines
- Always use the Grep tool for searching, never `grep` or `rg` in bash
- Use the Task tool for complex multi-step operations
- Batch file reads/writes when processing multiple files
- Prefer editing existing files over creating new ones

### Session Management
- Track story progress throughout the session
- Update checkboxes immediately after completing tasks
- Maintain context of the current story being worked on
- Save important state before long-running operations

### Error Recovery
- Always provide recovery suggestions for failures
- Include error context in messages to user
- Suggest rollback procedures when appropriate
- Document any manual fixes required

### Testing Strategy
- Run tests incrementally during development
- Always verify lint and typecheck before marking complete
- Test edge cases for each new feature
- Document test scenarios in story files

### Documentation
- Update relevant docs when changing functionality
- Include code examples in documentation
- Keep README synchronized with actual behavior
- Document breaking changes prominently

## Spalla Dashboard — Direct Access & Credentials

### Supabase (Database)
- **URL:** `https://knusqfbvhsqworzyhvip.supabase.co`
- **Anon Key:** In `.env` and `11-APP-app.js` CONFIG object
- **REST API:** Always use curl to query/update Supabase directly via REST API
- **Pattern for SELECT:** `curl -s "$SUPABASE_URL/rest/v1/TABLE?select=COLS&FILTERS" -H "apikey: $KEY" -H "Authorization: Bearer $KEY"`
- **Pattern for UPDATE:** `curl -s "$SUPABASE_URL/rest/v1/TABLE?id=eq.ID" -X PATCH -H "apikey: $KEY" -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -d '{"col":"val"}'`
- **Pattern for INSERT:** Same as UPDATE but use `-X POST` and body is the new row JSON
- **Key Tables:** `mentorados`, `calls_mentoria`, `god_tasks`, `god_reminders`, `pa_planos`, `pa_fases`, `pa_acoes`, `ob_trilhas`, `ds_producoes`
- **Key Views:** `vw_god_overview`, `vw_god_calls`, `vw_god_tarefas`, `vw_god_vendas`, `vw_god_timeline`
- **ALWAYS query Supabase before generating UPDATE SQL** to verify current state and avoid overwriting existing data

### Evolution API (WhatsApp)
- **Base URL:** `https://evolution.manager01.feynmanproject.com`
- **Instance:** `producao002`
- **API Key:** In `12-APP-data.js` EVOLUTION_CONFIG
- **Proxied via Railway:** `https://web-production-2cde5.up.railway.app/api/evolution/`

### Railway (Backend Server)
- **URL:** `https://web-production-2cde5.up.railway.app`
- **Server:** `14-APP-server.py` (Python/Flask)
- **Endpoints:** `/api/health`, `/api/auth/*`, `/api/evolution/*`, `/api/zoom/*`, `/api/sheets/*`
- **Docker:** Dockerfile in repo root, auto-deploys on push to main

### Vercel (Frontend)
- **Auto-deploy:** Yes, triggers on push to main
- **Build:** Static SPA (no build step)
- **Config:** `vercel.json` with SPA rewrite

### Key Behaviors
- **When user asks to update data:** Query Supabase first, check what exists, then PATCH only missing fields
- **When user asks to query data:** Use curl with Supabase REST API directly
- **When deploying:** Push to main triggers both Vercel (frontend) and Railway (backend)
- **Cache busting:** Bump `?v=XX` on script/style tags in `10-APP-index.html` after any JS/CSS change

---
*Synkra AIOS Claude Code Configuration v2.0*