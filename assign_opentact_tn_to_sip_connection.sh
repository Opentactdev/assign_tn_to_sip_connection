#!/usr/bin/env bash
BEARER="YOUR_OPENTACT_TOKEN"
SIP_CONN_UUID="YOUR_SIP_CONN_UUID"
TAKE=100
SKIP=0
DATA=$(curl -X POST "https://api.opentact.org/rest/lease/tn/search?bearer=${BEARER}" -H  "Content-Type: application/json" -d "{\"take\":${TAKE},\"skip\":${SKIP}}" 2>/dev/null | jq '.payload')
TOTAL=$(echo  ${DATA} | jq '.total')
DATA=$(echo  ${DATA} | jq '.data')

while [ $(echo ${DATA} | jq length) -ne 0 ]; do
  echo -n $SKIP" - "$(($SKIP + $TAKE))" / "$TOTAL" ..."
  REQ="{\"add\":["
  UUIDS=$(echo $DATA | jq '.[].uuid')
  REQ="${REQ}"$(echo ${UUIDS} | sed -e 's/" "/", "/g')
  REQ="${REQ}]}"
  RES=$(curl -X POST "https://api.opentact.org/rest/sip/connection/${SIP_CONN_UUID}/tnlease?bearer=${BEARER}" -H  "Content-Type: application/json" -d "${REQ}" 2>/dev/null)
  echo " "$(echo $RES | jq '.success')
  SKIP=$(($SKIP + $TAKE))
  DATA=$(curl -X POST "https://api.opentact.org/rest/lease/tn/search?bearer=${BEARER}" -H  "Content-Type: application/json" -d "{\"take\":${TAKE},\"skip\":${SKIP}}" 2>/dev/null | jq '.payload.data')
done
