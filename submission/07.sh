# Create a raw transaction with an amount of 20,000,000 satoshis to this address: 2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP
# Use the UTXOs from the transaction below
# raw_tx="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"
#!/bin/bash
set -euo pipefail

BASE_TX="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"
TARGET="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
PAY_SATS=20000000
FEE_SATS=10000

TXID=$(bitcoin-cli -regtest decoderawtransaction "$BASE_TX" | jq -r .txid)

read -r VOUT0_SATS VOUT1_SATS <<< "$(bitcoin-cli -regtest decoderawtransaction "$BASE_TX" | jq -r '.vout[0].value, .vout[1].value' | awk '{printf "%.0f\n", $1*1e8}')"
TOTAL_SATS=$((VOUT0_SATS + VOUT1_SATS))
CHANGE_SATS=$((TOTAL_SATS - PAY_SATS - FEE_SATS))

if [ "$CHANGE_SATS" -lt 0 ]; then
  echo "ERROR: insufficient funds" >&2
  exit 1
fi

CHANGE_ADDR=$(bitcoin-cli -regtest getrawchangeaddress)

toBTC(){ awk "BEGIN{printf \"%.8f\", $1/1e8}"; }
PAY_BTC=$(toBTC $PAY_SATS)
CHANGE_BTC=$(toBTC $CHANGE_SATS)

INPUTS="[{\"txid\":\"$TXID\",\"vout\":0},{\"txid\":\"$TXID\",\"vout\":1}]"
OUTPUTS="{\"$TARGET\":$PAY_BTC,\"$CHANGE_ADDR\":$CHANGE_BTC}"

RAW=$(bitcoin-cli -regtest createrawtransaction "$INPUTS" "$OUTPUTS")
SIGNED=$(bitcoin-cli -regtest signrawtransactionwithwallet "$RAW" | jq -r .hex)

echo "$SIGNED"
