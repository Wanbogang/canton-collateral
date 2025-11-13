#!/bin/bash

# --- CONFIGURATION ---
LEDGER_HOST="localhost"
LEDGER_PORT="7575"
LEDGER_ID="sandbox"
SECRET="secret"

# Party IDs (dapatkan dari 'daml ledger list-parties')
BANKA_ID="party-7a75974e-60f7-4471-a8ad-f324e34fdcc6::1220d751f283b04ca60cc2fc3a2beb034085b422d312c3c96f9343f125b8df849a3a"
BROKERB_ID="party-693be0ce-23bf-4ae8-9f9a-52a930632753::1220d751f283b04ca60cc2fc3a2beb034085b422d312c3c96f9343f125b8df849a3a"
TEMPLATE_ID="df84d1f6420fafde22fe4600050183faa09f6e75c840c0f0754ba8b3dca81977:PledgeAgreement:PledgeAgreement"

# --- HELPER FUNCTIONS ---
create_token() {
  local PARTY_ID=$1
  python3 -c "
import jwt, time
payload = {
    'ledgerId': '$LEDGER_ID',
    'applicationId': 'collateral-app',
    'actAs': ['$PARTY_ID'],
    'readAs': [],
    'exp': int(time.time()) + 3600
}
token = jwt.encode(payload, '$SECRET', algorithm='HS256')
print(token)
"
}

# --- WORKFLOW ---
echo "--- Starting Collateral Mobility Demo ---"

# 1. BankA creates a PledgeAgreement
echo "Step 1: BankA is pledging collateral to BrokerB..."
BANKA_TOKEN=$(create_token $BANKA_ID)
PLEDGE_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $BANKA_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
        \"templateId\": \"$TEMPLATE_ID\",
        \"payload\": {
          \"collateralOwner\": \"$BANKA_ID\",
          \"collateralReceiver\": \"$BROKERB_ID\",
          \"collateralId\": \"BOND-002\"
        }
      }" \
  "http://$LEDGER_HOST:$LEDGER_PORT/v1/create")

CONTRACT_ID=$(echo $PLEDGE_RESPONSE | jq -r '.result.contractId')
echo "✅ Pledge successful! Contract ID: $CONTRACT_ID"
echo ""

# 2. BrokerB releases the collateral
echo "Step 2: BrokerB is releasing the collateral..."
BROKERB_TOKEN=$(create_token $BROKERB_ID)
RELEASE_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $BROKERB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
        \"templateId\": \"$TEMPLATE_ID\",
        \"contractId\": \"$CONTRACT_ID\",
        \"choice\": \"Release\",
        \"argument\": {}
      }" \
  "http://$LEDGER_HOST:$LEDGER_PORT/v1/exercise")

echo "✅ Release successful!"
echo ""

# 3. Verify the contract is gone
echo "Step 3: Verifying contract is archived..."
VERIFY_RESPONSE=$(curl -s -H "Authorization: Bearer $BANKA_TOKEN" "http://$LEDGER_HOST:$LEDGER_PORT/v1/query?template_ids=$TEMPLATE_ID")
RESULT_COUNT=$(echo $VERIFY_RESPONSE | jq '.result | length')

if [ "$RESULT_COUNT" -eq 0 ]; then
  echo "✅ Verification successful! No active PledgeAgreement contracts found."
else
  echo "❌ Verification failed! Found $RESULT_COUNT active contracts."
fi

echo "--- Demo Finished ---"
