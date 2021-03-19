# assign_tn_to_sip_connection
This script help Opentact User to associate all their TN to a SIP Connection

## Preparation
1) [Create sip connection](https://api.opentact.org/swagger/?urls.primaryName=TAG%3A%20SIP_Connection#/SIP%20Connection/CreateSIPConnection)
2) [Create bearer token](https://api.opentact.org/swagger/?urls.primaryName=TAG%3A%20Auth#/Auth/CreateToken)
3) `jq` tool must be installed:
   * MacOS: `brew install jq`
   * Linux
      * `apt install jq`
      * `yum add jq`

## Execution
 ```shell
./assign_opentact_tn_to_sip_connection.sh "BEARER TOKEN" "SIP CONNECTION UUID"
```

### Hints
* if all numbers already assigned to provided sip connection, u will see message: `0 non-related numbers found`
