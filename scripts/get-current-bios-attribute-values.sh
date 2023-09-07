#!/usr/bin/env bash

: ${BMC_HOST:="YOUR_BMC_HOSTNAME_OR_IP"}
: ${BMC_USER:="YOUR_BMC_USER_NAME"}
: ${BMC_PASS:="YOUR_BMC_PASSWORD"}

curl_="curl -sLk \
    -H 'OData-Version: 4.0' \
    -H 'Content-Type: application/json; charset=utf-8' \
    -u ${BMC_USER}:${BMC_PASS} \
    https://${BMC_HOST}"

function get_current_bios_attribute_values {

    system_uri=$(${curl_}/redfish/v1/Systems/ \
        | jq -r '.Members[0]."@odata.id"')

    bios_attr_uri=$(${curl_}${system_uri} \
        | jq -r '."Bios"."@odata.id"')

    ${curl_}${bios_attr_uri} \
        | jq '."Attributes"'
}

get_current_bios_attribute_values
