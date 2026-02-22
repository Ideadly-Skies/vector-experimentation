# Vector Experimentation - Production-Ready Setup

## Overview

This project implements a production-ready Vector agent-to-gateway architecture with HTTPS/TLS encryption for secure log processing and forwarding.

## Features

- ✅ **HTTPS/TLS Encryption**: Secure communication between agent and gateway
- ✅ **Environment-based Configuration**: Externalized configuration via `.env` file
- ✅ **Structured Log Parsing**: VRL-based parsing of SSBAdapter logs
- ✅ **Production Features**: Retries, compression, batching, acknowledgements
- ✅ **Self-signed Certificates**: Easy development setup with certificate generation
- ✅ **Health Checks**: Built-in health monitoring

## Quick Start

### 1. Initial Setup

```bash
# Copy environment template
cp .env.example .env

# Generate SSL/TLS certificates
./scripts/generate-certs.sh

# Review configuration
cat .env
```

### 2. Start Services

**Terminal 1 - Gateway:**

```bash
./scripts/run-vector-gateway.sh
```

**Terminal 2 - Agent:**

```bash
./scripts/run-vector.sh
```

### 3. Verify

You should see structured JSON logs appearing in the gateway terminal, indicating successful HTTPS communication.

## Project Structure

```
.
├── .env                      # Environment configuration (create from .env.example)
├── .env.example              # Environment template
├── .gitignore                # Git ignore rules
├── README.md                 # This file
├── agent/                    # Vector Agent (modular configuration)
│   ├── vector.yaml          # Root orchestration for agent
│   ├── sources/             # Source configurations
│   │   └── adapter_logs.yaml
│   ├── transforms/          # VRL transformation scripts
│   │   └── parse_adapter_logs.vrl
│   └── sinks/               # Sink configurations
│       ├── console_out.yaml
│       └── to_gateway.yaml
├── gateway/                  # Vector Gateway (modular configuration)
│   ├── vector.yaml          # Root orchestration for gateway
│   ├── sources/             # Source configurations
│   │   └── from_agent.yaml
│   └── sinks/               # Sink configurations
│       └── console_output.yaml
├── scripts/                  # Operational scripts
│   ├── generate-certs.sh    # SSL certificate generation
│   ├── run-vector.sh        # Start agent
│   ├── run-vector-gateway.sh # Start gateway
│   ├── reset-vector.sh      # Reset checkpoint data
│   ├── rotate-logs.sh       # Log rotation
│   └── validate-setup.sh    # Validation script
├── certs/                    # SSL/TLS certificates (generated)
│   ├── ca.crt               # Certificate Authority
│   ├── ca.key               # CA private key
│   ├── gateway.crt          # Gateway certificate
│   └── gateway.key          # Gateway private key
├── data/                     # Data directories
│   ├── agent/               # Agent checkpoint data
│   ├── gateway/             # Gateway checkpoint data
│   ├── examples/            # Sample log files
│   │   └── SSBAdapter.log
│   ├── logs-archive/        # Archived logs
│   └── backup-original/     # Original data backups
└── docs/                     # Documentation
    └── AGENT_GATEWAY_SETUP.md
```

## Configuration

All configuration is externalized through environment variables in the `.env` file:

### Key Variables

- `VECTOR_GATEWAY_PROTOCOL`: Protocol to use (default: `https`)
- `VECTOR_GATEWAY_HOST`: Gateway hostname (default: `localhost`)
- `VECTOR_GATEWAY_PORT`: Gateway port (default: `8686`)
- `TLS_CA_FILE`: CA certificate path
- `TLS_GATEWAY_CERT_FILE`: Gateway certificate path
- `TLS_GATEWAY_KEY_FILE`: Gateway private key path
- `LOG_FILE_PATH`: Path to log file to process

See `.env.example` for all available options.

## Common Tasks

### Reset and Re-process Logs

```bash
./scripts/reset-vector.sh
```

This will:

- Stop all Vector processes
- Clear checkpoint data for both agent and gateway
- Prepare for fresh start

### Test HTTPS Connection

```bash
# Test gateway endpoint (ignore self-signed cert)
curl -k -X POST https://localhost:8686 \
  -H "Content-Type: application/json" \
  -d '{"test": "message"}'

# Test with certificate verification
curl --cacert ./certs/ca.crt -X POST https://localhost:8686 \
  -H "Content-Type: application/json" \
  -d '{"test": "message"}'
```

### Regenerate Certificates

```bash
rm -rf certs/
./scripts/generate-certs.sh
```

### Stop Services

```bash
pkill -f "vector --config agent/vector.yaml"
pkill -f "vector --config gateway/vector.yaml"
```

## Architecture

```
┌─────────────────────┐      HTTPS/TLS (Port 8686)      ┌──────────────────────┐
│   Vector Agent      │ ──────────────────────────────> │   Vector Gateway     │
│  (SSBAdapter Logs)  │    • Encrypted                  │   (Console Output)   │
│                     │    • Certificate Verification   │                      │
│  - File Source      │    • Gzip Compression          │  - HTTP Server       │
│  - VRL Parser       │    • Retry Logic               │  - Console Sink      │
│  - HTTP Sink        │    • Acknowledgements          │                      │
└─────────────────────┘                                  └──────────────────────┘
```

## Documentation

- **[PRODUCTION_SETUP.md](PRODUCTION_SETUP.md)**: Comprehensive production deployment guide
- **[AGENT_GATEWAY_SETUP.md](AGENT_GATEWAY_SETUP.md)**: Agent-to-gateway architecture details
- **[IMPLEMENTATION_SUMMARY.txt](IMPLEMENTATION_SUMMARY.txt)**: Historical implementation notes

## Security

### Development

- Self-signed certificates are generated for easy development
- Certificate verification is enabled

### Production

- Replace self-signed certificates with CA-signed certificates
- Store private keys securely
- Rotate certificates regularly
- Enable mutual TLS (mTLS) for enhanced security
- Use secret management systems for `.env` file

### Important Files to Protect

- `.env` - Contains configuration (DO NOT COMMIT)
- `certs/*.key` - Private keys (DO NOT COMMIT)
- See `.gitignore` for protected files

## Troubleshooting

### Gateway not starting

- Check if port 8686 is already in use: `lsof -i :8686`
- Verify certificates exist: `ls -la certs/`
- Check `.env` file exists and is loaded

### Agent can't connect to gateway

- Ensure gateway is running: `ps aux | grep vector-gateway`
- Verify protocol matches (https): `echo $VECTOR_GATEWAY_PROTOCOL`
- Check certificate paths in `.env`

### Certificate verification errors

- Verify CA certificate path is correct
- Ensure gateway certificate is signed by the CA
- Try with verification disabled temporarily: Set `verify_certificate: false` (dev only)

### No logs appearing

- Check log file exists: `ls -la example-data/SSBAdapter.log`
- Verify file path in `.env`: `LOG_FILE_PATH`
- Check agent is reading: Look for "file opened" messages

## Performance

### Current Configuration

- **Compression**: gzip (reduces bandwidth ~70%)
- **Batch Size**: Up to 1000 events or 10MB
- **Batch Timeout**: 1 second
- **Retry Attempts**: 5 attempts with exponential backoff
- **Request Timeout**: 60 seconds

### Tuning Tips

- Increase batch size for higher throughput
- Decrease batch timeout for lower latency
- Adjust retry settings based on network reliability
- Monitor Vector metrics for optimization

## Development vs Production

| Feature      | Development     | Production          |
| ------------ | --------------- | ------------------- |
| Certificates | Self-signed     | CA-signed           |
| Environment  | `.env` file     | Secret manager      |
| Verification | Enabled         | Enabled             |
| Monitoring   | Console logs    | Centralized logging |
| Scale        | Single instance | Multiple instances  |

## Requirements

- Vector v0.53.0 or later
- OpenSSL (for certificate generation)
- Bash shell (macOS/Linux)

## Vector Version

```bash
vector --version
```

Expected: `vector 0.53.0` or later

## Support

For issues or questions, refer to:

- [Vector Documentation](https://vector.dev/docs/)
- Production setup guide: [PRODUCTION_SETUP.md](PRODUCTION_SETUP.md)
- Internal team wiki

## License

Internal use - CIMB Niaga

---

**Last Updated**: February 18, 2026
**Status**: Production Ready
