# Migration to Modular Structure

## What Changed

The project has been restructured to follow industry best practices for Vector configuration management, with a modular, component-based organization.

## Directory Structure Changes

### Before:

```
.
├── vector.yaml               # Monolithic agent config
├── vector-gateway.yaml       # Monolithic gateway config
├── *.sh scripts              # Scripts at root
├── example-data/             # Log examples
├── vector-data/              # Agent data
├── vector-data-gateway/      # Gateway data
└── AGENT_GATEWAY_SETUP.md    # Docs at root
```

### After:

```
.
├── agent/                    # Agent modular configuration
│   ├── vector.yaml          # Root orchestration
│   ├── sources/             # Source configurations
│   ├── transforms/          # VRL transformation scripts
│   └── sinks/               # Sink configurations
├── gateway/                  # Gateway modular configuration
│   ├── vector.yaml          # Root orchestration
│   ├── sources/             # Source configurations
│   └── sinks/               # Sink configurations
├── scripts/                  # All operational scripts
├── data/                     # All data directories
│   ├── agent/               # Agent checkpoint data
│   ├── gateway/             # Gateway checkpoint data
│   ├── examples/            # Sample logs
│   ├── logs-archive/        # Archived logs
│   └── backup-original/     # Original data backups
├── docs/                     # All documentation
├── certs/                    # SSL/TLS certificates
└── README.md                # Main documentation
```

## Benefits of New Structure

1. **Modularity**: Configuration split into logical components
2. **Maintainability**: Easier to find and update specific configurations
3. **Scalability**: Simple to add new sources, transforms, or sinks
4. **Organization**: Clear separation of concerns
5. **Version Control**: Better diff tracking with smaller files
6. **Team Collaboration**: Multiple team members can work on different components

## How to Use

### Running the Services

The run scripts automatically load all modular configuration files:

```bash
# Start gateway
./scripts/run-vector-gateway.sh

# Start agent
./scripts/run-vector.sh
```

### Modular Configuration Loading

Vector loads multiple configuration files using the `--config-yaml` flag:

```bash
# Agent loads:
vector \
  --config-yaml agent/vector.yaml \
  --config-yaml agent/sources/adapter_logs.yaml \
  --config-yaml agent/transforms/parse_adapter_logs.yaml \
  --config-yaml agent/sinks/console_out.yaml \
  --config-yaml agent/sinks/to_gateway.yaml

# Gateway loads:
vector \
  --config-yaml gateway/vector.yaml \
  --config-yaml gateway/sources/from_agent.yaml \
  --config-yaml gateway/sinks/console_output.yaml
```

## Adding New Components

### Add a New Source

1. Create `agent/sources/new_source.yaml`
2. Update `scripts/run-vector.sh` to include the new file

### Add a New Transform

1. Create `agent/transforms/new_transform.vrl` (VRL script)
2. Create `agent/transforms/new_transform.yaml` (transform config referencing the VRL)
3. Update `scripts/run-vector.sh` to include the new file

### Add a New Sink

1. Create `agent/sinks/new_sink.yaml`
2. Update `scripts/run-vector.sh` to include the new file

## Backward Compatibility

The original monolithic configuration files have been preserved as:

- `vector.yaml.old`
- `vector-gateway.yaml.old`

You can reference these files if needed, but they are no longer used by the scripts.

## Updated Paths

All paths have been updated throughout the project:

| Old Path                   | New Path                        |
| -------------------------- | ------------------------------- |
| `./example-data/`          | `./data/examples/`              |
| `./vector-data/`           | `./data/agent/`                 |
| `./vector-data-gateway/`   | `./data/gateway/`               |
| `./logs-archive/`          | `./data/logs-archive/`          |
| `./backup-original-data/`  | `./data/backup-original/`       |
| `./*.sh`                   | `./scripts/*.sh`                |
| `./AGENT_GATEWAY_SETUP.md` | `./docs/AGENT_GATEWAY_SETUP.md` |

## Environment Variables

`.env` and `.env.example` have been updated with new default paths:

- `VECTOR_AGENT_DATA_DIR=./data/agent`
- `VECTOR_GATEWAY_DATA_DIR=./data/gateway`
- `LOG_FILE_PATH=./data/examples/*.log`

## Validation

To validate the modular configuration:

```bash
# Validate agent config
vector validate \
  agent/vector.yaml \
  agent/sources/adapter_logs.yaml \
  agent/transforms/parse_adapter_logs.yaml \
  agent/sinks/console_out.yaml \
  agent/sinks/to_gateway.yaml

# Validate gateway config
vector validate \
  gateway/vector.yaml \
  gateway/sources/from_agent.yaml \
  gateway/sinks/console_output.yaml

# Or use the validation script
./scripts/validate-setup.sh
```

## Next Steps

1. Review the new structure to familiarize yourself
2. Test the services: `./scripts/run-vector-gateway.sh` and `./scripts/run-vector.sh`
3. When comfortable, delete the `.old` backup files
4. Commit the new structure to version control

## References

This structure follows industry best practices as demonstrated in modern Vector deployments and provides a foundation for scaling to more complex configurations.
