#!/usr/bin/env bash
BEARER=$1
SIP_CONN_UUID=$2

TAKE=100
SKIP=0

if [[ "x$SIP_CONN_UUID" == "x" ]]; then
  echo "Usage: $0 <BEARER TOKEN> <SIP CONNECTION UUID>"
  exit 1
fi

function getNext() {
  res=$(curl -X POST "https://api.opentact.org/rest/lease/tn/search?bearer=${BEARER}&take=$1&skip=$2" -H  "Content-Type: application/json" -d "{\"sip_connections_skip\":[\"${SIP_CONN_UUID}\"]}" 2>/dev/null)
  echo "${res}" | jq '.payload'
}

function getNextData() {
  next=$(getNext $1 $2)
  echo "${next}" | jq '.data'
}

function assign() {
  UUIDS=$(echo $1 | jq '.[].uuid')
  REQ="{\"add\":["
  REQ="${REQ}"$(echo ${UUIDS} | sed -e 's/" "/","/g')
  REQ="${REQ}]}"
  curl -X POST "https://api.opentact.org/rest/sip/connection/${SIP_CONN_UUID}/tnlease?bearer=${BEARER}" -H "Content-Type: application/json" -d "${REQ}" 2>/dev/null
}

DATA=$(getNext $TAKE $SKIP)
TOTAL=$(echo "${DATA}" | jq '.total')
echo "${TOTAL} non-related numbers found"
DATA=$(echo "${DATA}" | jq '.data')
while [ "$(echo "${DATA}" | jq length)" -ne 0 ]; do
  echo -n $SKIP" - "$((${SKIP} + ${TAKE}))" / ${TOTAL} ... "
  RES=$(assign "${DATA}")

  if [[ $(echo "${RES}" | jq '.success') == "true" ]]; then
    echo "success"
  else
    echo "FAILED: $(echo "${RES}" | jq '.message')"
  fi

  SKIP=$((${SKIP} + ${TAKE}))
  DATA=$(getNextData $TAKE $SKIP)
done
