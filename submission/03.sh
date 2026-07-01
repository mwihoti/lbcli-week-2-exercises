# Create a SegWit address.
# Add funds to the address.
# Return only the Address
ADDR=$(bitcoin-cli -regtest getnewaddress "" bech32)
bitcoin-cli -regtest generatetoaddress 1 "$ADDR" > /dev/null
echo "$ADDR"
