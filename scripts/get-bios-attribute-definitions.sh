#!/usr/bin/env bash

: ${BMC_HOST:="YOUR_BMC_HOSTNAME_OR_IP"}
: ${BMC_USER:="YOUR_BMC_USER_NAME"}
: ${BMC_PASS:="YOUR_BMC_PASSWORD"}

curl_="curl -sLk \
    -H 'OData-Version: 4.0' \
    -H 'Content-Type: application/json; charset=utf-8' \
    -u ${BMC_USER}:${BMC_PASS} \
    https://${BMC_HOST}"

function get_bios_attributes {

    bios_attr_uri=$(${curl_}/redfish/v1/Registries/ \
        | jq -r '.Members[]."@odata.id" | match("(/.*BiosAttribute.*)").string')

    bios_attr_jsonschema_uri=$(${curl_}${bios_attr_uri} \
        | jq -r '."Location"[] | select(."Language" == "en" or ."Language" == "en-US")."Uri"')

    bios_attr_tmpfile=$(mktemp -t bios_attr)
    ${curl_}${bios_attr_jsonschema_uri} > $bios_attr_tmpfile
    if [[ "$(file ${bios_attr_tmpfile} | grep ':.*gzip compressed data')" == "" ]]; then
        cat ${bios_attr_tmpfile} \
        | jq '."RegistryEntries"."Attributes"'
    else
        cat ${bios_attr_tmpfile} \
        | gunzip \
        | jq '."RegistryEntries"."Attributes"'
    fi
    rm -f $bios_attr_tmpfile
}

get_bios_attributes
