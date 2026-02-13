# Vector Agent-to-Gateway Setup

## Architecture

```
SSBAdapter.log → Vector Agent → Vector Gateway → Console Output
                 (vector.yaml)   (vector-gateway.yaml)
                                 (localhost:8686)
```

## How to Run

### Step 1: Start the Vector Gateway (Terminal 1)
```bash
./run-vector-gateway.sh
```

The gateway will:
- Listen on http://localhost:8686
- Receive JSON logs from the agent
- Print all received logs to console

### Step 2: Start the Vector Agent (Terminal 2)
```bash
./reset-vector.sh && ./run-vector.sh
```

The agent will:
- Read logs from ./example-data/SSBAdapter.log
- Parse and structure the logs
- Send JSON via HTTP POST to gateway at localhost:8686
- Also output to its own console for debugging

## Verification

You should see:
1. **Gateway terminal**: Structured JSON logs appearing in real-time
2. **Agent terminal**: Same logs (agent console output)

## Configuration Files

- `vector.yaml` - Agent configuration (reads files, parses, sends to gateway)
- `vector-gateway.yaml` - Gateway configuration (receives HTTP, outputs console)
- `run-vector.sh` - Start the agent
- `run-vector-gateway.sh` - Start the gateway

## Stopping

Press `Ctrl+C` in each terminal, or:
```bash
pkill -f "vector --config vector.yaml"
pkill -f "vector --config vector-gateway.yaml"
```

## Architecture Notes

This simulates a distributed Vector deployment:
- **Agent**: Runs on application servers, collects and forwards logs
- **Gateway**: Centralized aggregation point, processes/routes logs

In production, the gateway would typically forward to:
- Loki, Elasticsearch, or other storage
- Multiple destinations (fan-out)
- Cloud-based observability platforms
