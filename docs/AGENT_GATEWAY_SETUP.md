# Vector Agent-to-Gateway Setup

## Architecture

```
SSBAdapter.log → Vector Agent → Vector Gateway → Console Output
                 (agent/vector.yaml)   (gateway/vector.yaml)
                                 (localhost:8686)
```

## How to Run

### Step 1: Start the Vector Gateway (Terminal 1)

```bash
./scripts/run-vector-gateway.sh
```

The gateway will:

- Listen on http://localhost:8686
- Receive JSON logs from the agent
- Print all received logs to console

### Step 2: Start the Vector Agent (Terminal 2)

```bash
./scripts/reset-vector.sh && ./scripts/run-vector.sh
```

The agent will:

- Read logs from ./data/examples/SSBAdapter.log
- Parse and structure the logs
- Send JSON via HTTP POST to gateway at localhost:8686
- Also output to its own console for debugging

## Verification

You should see:

1. **Gateway terminal**: Structured JSON logs appearing in real-time
2. **Agent terminal**: Same logs (agent console output)

## Configuration Files

- `agent/vector.yaml` - Agent root orchestration
- `agent/sources/` - Source configurations
- `agent/transforms/` - VRL transformation scripts
- `agent/sinks/` - Sink configurations
- `gateway/vector.yaml` - Gateway root orchestration
- `gateway/sources/` - Gateway sources
- `gateway/sinks/` - Gateway sinks
- `scripts/run-vector.sh` - Start the agent
- `scripts/run-vector-gateway.sh` - Start the gateway

## Stopping

Press `Ctrl+C` in each terminal, or:

```bash
pkill -f "vector --config agent/vector.yaml"
pkill -f "vector --config gateway/vector.yaml"
```

## Architecture Notes

This simulates a distributed Vector deployment:

- **Agent**: Runs on application servers, collects and forwards logs
- **Gateway**: Centralized aggregation point, processes/routes logs

In production, the gateway would typically forward to:

- Loki, Elasticsearch, or other storage
- Multiple destinations (fan-out)
- Cloud-based observability platforms
