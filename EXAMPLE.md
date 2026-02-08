# Vector Processing Example - SSBAdapter Logs

## What Was Configured

### 1. Data Directory ✅

Created `vector-data/` for Vector to store its state and file checkpoints.

### 2. Vector Configuration ✅

[vector.yaml](vector.yaml) is configured with:

#### Source

- Reads `example-data/SSBAdapter.log`
- Processes from beginning (all 100+ lines)
- Continues tailing for new entries

#### Transform (VRL)

Parses human-readable log format into structured JSON:

**Input Format:**

```
[2025-05-10 10:49:56.420]  INFO - [X'414d5120554944504f503031202020203a8118681367b540'] - ********** START HTTP **********
```

**Output Format:**

```json
{
  "timestamp": "2025-05-10 10:49:56.420",
  "log_level": "INFO",
  "correlation_id": "X'414d5120554944504f503031202020203a8118681367b540'",
  "log_message": "********** START HTTP **********",
  "event_type": "http_start",
  "source_file": "SSBAdapter.log",
  "adapter_type": "SSB",
  "@timestamp": "2025-05-10T10:49:56.420Z"
}
```

#### Intelligent Parsing

The VRL script extracts:

- **event_type**: Categorizes logs (http_start, token_start, message_sent, etc.)
- **Transaction details**: ParentTranSeqId, RqUID when present
- **URLs**: Target URLs from "Message has been sent" logs
- **Source systems**: From "SourceSystem" logs

#### Sink

- Console output (JSON format)
- Easy to add: HTTP gateway, Elasticsearch, file output, etc.

## Running Vector

### Quick Start

```bash
./run-vector.sh
```

### Validation

```bash
./validate-setup.sh
```

### Command Line

```bash
vector --config vector.yaml
```

## Example Output

When you run Vector, you'll see output like:

```json
{"timestamp":"2025-05-10 10:49:56.420","log_level":"INFO","correlation_id":"X'414d5120554944504f503031202020203a8118681367b540'","log_message":"********** START HTTP **********","event_type":"http_start","source_file":"SSBAdapter.log","adapter_type":"SSB","@timestamp":"2025-05-10T10:49:56.420Z"}

{"timestamp":"2025-05-10 10:49:56.420","log_level":"INFO","correlation_id":"X'414d5120554944504f503031202020203a8118681367b540'","log_message":"ParentTranSeqId = 91196B85031FE1RJ, RqUID = 842VUYm8Z2uixmHXsFhchtZV, CorrelId = X'414d5120554944504f503031202020203a8118681367b540'","event_type":"transaction_info","parent_transaction_seq_id":"91196B85031FE1RJ","request_uid":"842VUYm8Z2uixmHXsFhchtZV","correlation_id_detail":"X'414d5120554944504f503031202020203a8118681367b540'","source_file":"SSBAdapter.log","adapter_type":"SSB","@timestamp":"2025-05-10T10:49:56.420Z"}

{"timestamp":"2025-05-10 10:49:56.436","log_level":"INFO","correlation_id":"X'414d5120554944504f503031202020203a8118681367b540'","log_message":"Message has been sent. URL = https://ssbuat.mylab.local/api/channel-gateway-service/v1/validate-open-account","event_type":"message_sent","target_url":"https://ssbuat.mylab.local/api/channel-gateway-service/v1/validate-open-account","source_file":"SSBAdapter.log","adapter_type":"SSB","@timestamp":"2025-05-10T10:49:56.436Z"}
```

## Architecture Benefits

✅ **Transformation at source**: Each server parses its own logs
✅ **Reduced network bandwidth**: Send structured JSON instead of raw text
✅ **Flexible routing**: Add multiple sinks (console, HTTP gateway, ES, S3)
✅ **Centralized format control**: Update VRL in one place
✅ **Ready for scale**: Deploy to all 10+ ACE servers

## Production Deployment

### For Gateway Forwarding

Add HTTP sink to [vector.yaml](vector.yaml):

```yaml
sinks:
  gateway:
    type: http
    inputs:
      - parse_ssb_logs
    uri: http://your-gateway:8080/logs
    encoding:
      codec: json
    batch:
      max_bytes: 1048576
      timeout_secs: 5
```

### For Elasticsearch/OpenSearch

```yaml
sinks:
  elasticsearch:
    type: elasticsearch
    inputs:
      - parse_ssb_logs
    endpoints:
      - http://es-cluster:9200
    index: ssb-logs-%Y.%m.%d
```

### For OpenTelemetry

```yaml
sinks:
  otlp:
    type: opentelemetry
    inputs:
      - parse_ssb_logs
    endpoint: http://otel-collector:4317
```

## Testing Real-Time Processing

1. Start Vector:

```bash
./run-vector.sh
```

2. In another terminal, add a test log:

```bash
echo '[2026-02-08 12:00:00.000]  INFO - [X'"'"'TEST123'"'"'] - ********** START HTTP **********' >> example-data/SSBAdapter.log
```

3. Watch Vector console for immediate processing

## File Structure

```
.
├── vector.yaml           # Main configuration
├── vector-data/          # Vector state (auto-created)
├── run-vector.sh         # Start Vector
├── validate-setup.sh     # Validate setup
├── demo.sh              # Quick demo
├── README.md            # Full documentation
├── EXAMPLE.md           # This file
└── example-data/
    └── SSBAdapter.log   # Source log file (100+ lines)
```

## Next Steps

1. ✅ **Test locally**: Run `./run-vector.sh` to see it work
2. 📝 **Customize VRL**: Modify parsing in [vector.yaml](vector.yaml) line 20-80
3. 🚀 **Add sinks**: Configure HTTP/ES/OTel output
4. 📦 **Deploy**: Copy to all ACE servers
5. 🔧 **Tune**: Add sampling, filtering, batching as needed

## Questions?

- VRL documentation: https://vector.dev/docs/reference/vrl/
- Vector configuration: https://vector.dev/docs/reference/configuration/
- Examples: https://vector.dev/docs/setup/going-to-prod/

## Summary

Your Vector setup is ready to:

1. ✅ Read SSBAdapter.log files
2. ✅ Parse human-readable format to structured JSON
3. ✅ Extract event types and transaction details
4. ✅ Output to console (ready to add gateway/ES/OTel)
5. ✅ Handle log rotation
6. ✅ Scale to multiple servers

**Run it now:** `./run-vector.sh`
