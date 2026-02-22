#!/bin/bash
# Generate self-signed SSL certificates for Vector Gateway
# For production, replace with certificates from a trusted CA

set -e

# Get script directory and change to project root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."

CERT_DIR="./certs"
DAYS_VALID=365

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Generating SSL/TLS certificates for Vector Gateway...${NC}"

# Create certs directory if it doesn't exist
mkdir -p "$CERT_DIR"

# Generate CA private key
echo "1. Generating CA private key..."
openssl genrsa -out "$CERT_DIR/ca.key" 4096

# Generate CA certificate
echo "2. Generating CA certificate..."
openssl req -new -x509 -days $DAYS_VALID -key "$CERT_DIR/ca.key" -out "$CERT_DIR/ca.crt" \
  -subj "/C=ID/ST=Jakarta/L=Jakarta/O=CIMB Niaga/OU=Engineering/CN=Vector CA"

# Generate Gateway private key
echo "3. Generating Gateway private key..."
openssl genrsa -out "$CERT_DIR/gateway.key" 4096

# Generate Gateway CSR (Certificate Signing Request)
echo "4. Generating Gateway CSR..."
openssl req -new -key "$CERT_DIR/gateway.key" -out "$CERT_DIR/gateway.csr" \
  -subj "/C=ID/ST=Jakarta/L=Jakarta/O=CIMB Niaga/OU=Engineering/CN=localhost"

# Create extensions file for SAN (Subject Alternative Names)
cat > "$CERT_DIR/gateway.ext" << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = vector-gateway
DNS.3 = *.local
IP.1 = 127.0.0.1
IP.2 = 0.0.0.0
EOF

# Sign Gateway certificate with CA
echo "5. Signing Gateway certificate with CA..."
openssl x509 -req -in "$CERT_DIR/gateway.csr" -CA "$CERT_DIR/ca.crt" -CAkey "$CERT_DIR/ca.key" \
  -CAcreateserial -out "$CERT_DIR/gateway.crt" -days $DAYS_VALID \
  -extfile "$CERT_DIR/gateway.ext"

# Set appropriate permissions
chmod 600 "$CERT_DIR"/*.key
chmod 644 "$CERT_DIR"/*.crt

# Clean up temporary files
rm -f "$CERT_DIR/gateway.csr" "$CERT_DIR/gateway.ext" "$CERT_DIR/ca.srl"

echo -e "${GREEN}✓ SSL certificates generated successfully!${NC}"
echo ""
echo "Generated files:"
echo "  - CA Certificate: $CERT_DIR/ca.crt"
echo "  - CA Private Key: $CERT_DIR/ca.key"
echo "  - Gateway Certificate: $CERT_DIR/gateway.crt"
echo "  - Gateway Private Key: $CERT_DIR/gateway.key"
echo ""
echo -e "${YELLOW}Note: These are self-signed certificates for development.${NC}"
echo -e "${YELLOW}For production, use certificates from a trusted Certificate Authority.${NC}"
echo ""

# Verify certificates
echo "Verifying certificates..."
openssl verify -CAfile "$CERT_DIR/ca.crt" "$CERT_DIR/gateway.crt"
echo ""
openssl x509 -in "$CERT_DIR/gateway.crt" -text -noout | grep -A 1 "Subject:"
openssl x509 -in "$CERT_DIR/gateway.crt" -text -noout | grep -A 3 "Subject Alternative Name"
