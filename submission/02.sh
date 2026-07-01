# Create a new Bitcoin address, for receiving change.
#!/bin/bash
set -euo pipefail
bitcoin-cli -regtest getnewaddress "" bech32
