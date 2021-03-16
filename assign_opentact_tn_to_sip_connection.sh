#!/usr/bin/env bash
BEARER="YOUR_OPENTACT_TOKEN"
SIP_CONN_UUID="YOUR_SIP_CONN_UUID"

TAKE=100
SKIP=0

function getNext() {
  echo $(curl -X POST "https://api.opentact.org/rest/lease/tn/search?bearer=${BEARER}&take=$1&skip=$2" 2>/dev/null | jq '.payload')
}

function getNextData() {
  echo $(getNext $1 $2) | jq '.data'
}

function assign() {
  UUIDS=$(echo $1 | jq '.[].uuid')
  REQ="{\"add\":["
  REQ="${REQ}"$(echo ${UUIDS} | sed -e 's/" "/","/g')
  REQ="${REQ}]}"
  RES=$(curl -X POST "https://api.opentact.org/rest/sip/connection/${SIP_CONN_UUID}/tnlease?bearer=${BEARER}" -H "Content-Type: application/json" -d "${REQ}" 2>/dev/null)
  echo " $(echo "${RES}" | jq '.success')"
}

DATA=$(getNext $TAKE $SKIP)
TOTAL=$(echo "${DATA}" | jq '.total')
DATA=$(echo "${DATA}" | jq '.data')
while [ "$(echo "${DATA}" | jq length)" -ne 0 ]; do
  echo -n $SKIP" - "$((${SKIP} + ${TAKE}))" / ${TOTAL} ..."
  assign "${DATA}"

  SKIP=$((${SKIP} + ${TAKE}))
  DATA=$(getNextData $TAKE $SKIP)
done
