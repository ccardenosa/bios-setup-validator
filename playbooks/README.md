# Usage

## Help

The following command shows all available options:

```
$ ansible-playbook main.yaml [--tags help]
```

## Generate Inventories

To help in the task of generating the inveroties, run:

```
$ ansible-playbook main.yaml --tags generate-inventory-template
```

which it will generate an inventory template with all recommended BIOS attribute:

> **Note**: BIOS attribute can be added or removed manually if requiered. Use this template as a hint.

```
$ ansible-playbook main.yaml --tags generate-inventory-template
. . .
TASK [New Generate Inventories path] *******************************************
ok: [localhost] => {
    "msg": [
        "Find the auto-generate inventory at:",
        "/tmp/generated-inventory-auuuvsus/bmc-bmc-hosts.yaml",
        "/tmp/generated-inventory-auuuvsus/bmc-bios-attributes.yaml"
    ]
}
```

Additionally, it is possible to set a `label_id` (default value is `bmc`) and indicate the path to where you want these generated files are to be saved by using `inventory_folder` (both are optional):

```
$ ansible-playbook main.yaml --tags generate-inventory-template --extra-vars inventory_folder=/opt/bmc-vendor-inventories --extra-vars label_id=proteus_zt_systems
. . .
TASK [New Generate Inventories path] *******************************************
ok: [localhost] => {
    "msg": [
        "Find the auto-generate inventory at:",
        "/opt/bmc-vendor-inventories/proteus_zt_systems-bmc-hosts.yaml",
        "/opt/bmc-vendor-inventories/proteus_zt_systems-bios-attributes.yaml"
    ]
}
```
Fill in these templates with the appropriate values:

```
$ cat /opt/bmc-vendor-inventories/proteus_zt_systems-bmc-hosts.yaml
all:
  children:
    bmc:
      children:
        proteus_zt_systems:
          hosts:
            bmc_system_name_1:
              bmc_host: bmc_hostname_or_ip_1
            bmc_system_name_2:
              bmc_host: bmc_hostname_or_ip_2
            bmc_system_name_N:
              bmc_host: bmc_hostname_or_ip_N
          vars:
            bmc_password: ''
            bmc_username: ''

$ cat /opt/bmc-vendor-inventories/proteus_zt_systems-bios-attributes.yaml
proteus_zt_systems:
  vars:
    bios_attributes:
      Boot_Mode:
        value: ''
        vendor_label: ''
      C1E:
        value: ''
        vendor_label: ''
      CPU_Power_and_Performance_Policy:
        value: ''
        vendor_label: ''
      Configurable_TDP_Level:
        value: ''
        vendor_label: ''
      Energy_Efficient_Turbo:
        value: ''
        vendor_label: ''
      Enhanced_Intel_SpeedStep_Tech:
        value: ''
        vendor_label: ''
      Hardware_P_States:
        value: ''
        vendor_label: ''
      HyperThreading:
        value: ''
        vendor_label: ''
      HyperTransport:
        value: ''
        vendor_label: ''
      Intel_Configurable_TDP:
        value: ''
        vendor_label: ''
      Intel_Turbo_Boost_Technology:
        value: ''
        vendor_label: ''
      Package_C_State:
        value: ''
        vendor_label: ''
      Performance_P_limit:
        value: ''
        vendor_label: ''
      Processor_C6:
        value: ''
        vendor_label: ''
      Sub_NUMA_Clustering:
        value: ''
        vendor_label: ''
      Uncore_Frequency:
        value: ''
        vendor_label: ''
      Uncore_Frequency_Scaling:
        value: ''
        vendor_label: ''
      WorkloadProfile:
        value: ''
        vendor_label: ''
```

## Get BIOS attribute JSON Schemas

Whenever we need to get the BIOS JSON schemas having all related info to BIOS attribute to a particular hardware, you can run:

```
$ ansible-playbook main.yaml -i /opt/bmc-vendor-inventories --tags get-bios-attributes-jsonschema
. . .
TASK [New Generate JSON schema path] ********************************************************
ok: [cnfdf23 -> localhost] => {
    "msg": "Find the JSON schema path at /tmp/generated-schemas-ag4py9m1/10.20.30.40-vendor-bios-json-schema.yaml"
}
ok: [zt_sno3 -> localhost] => {
    "msg": "Find the JSON schema path at /tmp/generated-schemas-9_ntniy1/192.168.10.30-vendor-bios-json-schema.yaml"
}
```

Additionally, it is possible to indicate the path to where you want these files are to be saved by using `schemas_folder` (optional):

```
$ ansible-playbook main.yaml -i /opt/bmc-vendor-inventories --tags get-bios-attributes-jsonschema --extra-vars schemas_folder=/opt/json_schemas
. . .
TASK [New Generate JSON schema path] ********************************************************
ok: [cnfdf23 -> localhost] => {
    "msg": "Find the JSON schema path at /opt/json_schemas/10.20.30.40-vendor-bios-json-schema.yaml"
}
ok: [zt_sno3 -> localhost] => {
    "msg": "Find the JSON schema path at /opt/json_schemas/192.168.10.30-vendor-bios-json-schema.yaml"
}
```

The advantage of setting `schemas_folder` is that you can speed up other commands that it might use JSON schemas to check out BIOS attributes using these local files as cache but otherwise they had to fetch the remote info every time they are run.

> **Note**: The JSON schemas are saved in Yaml format.

## Show Current BIOS attribute values

If you want to get all available remote values of the BIOS attributes of the inventoried systems, run:

```
$ ansible-playbook main.yaml -i /opt/bmc-vendor-inventories --tags show-current-values
. . .
TASK [Print fetched information] ******************************************************
ok: [cnfdf23 -> localhost] => {
    "msg": {
        "changed": false,
        "failed": false,
        "redfish_facts": {
            "bios_attribute": {
                "entries": [
                    [
                        {
                            "system_uri": "/redfish/v1/Systems/System.Embedded.1"
                        },
                        {
                            "AcPwrRcvry": "Last",
                            "AcPwrRcvryDelay": "Immediate",
                            "AcPwrRcvryUserDelay": 60,
                            "AesNi": "Enabled",
                            "AssetTag": "",
                            "AuthorizeDeviceFirmware": "Disabled",
                            "AvxIccpPreGrantLevel": "IccpHeavy512",
. . .
ok: [zt_sno3 -> localhost] => {
    "msg": {
        "changed": false,
        "failed": false,
        "redfish_facts": {
            "bios_attribute": {
                "entries": [
                    [
                        {
                            "system_uri": "/redfish/v1/Systems/Self"
                        },
                        {
                            "ACPI002": false,
                            "ACPI004": false,
                            "CRCS005": "Disable",
                            "CSM000": "Force BIOS",
                            "CSM001": "Immediate",
                            "CSM002": "Upon Request",
                            "CSM005": "Disabled",
                            "CSM006": "UEFI only",
                            "CSM007": "UEFI",
```

> **Note**: You have to redirect the output to a file in case you want to save it.

## Get current BIOS attribute values in your inventory

Once you are set `vendor_label` for each BIOS attribute in your inventory file:


```
$ cat /opt/bmc-vendor-inventories/proteus_zt_systems-bios-attributes.yaml
proteus_zt_systems:
  vars:
    bios_attributes:
      Boot_Mode:
        - vendor_label: CSM007
        - vendor_label: CSM008
        - vendor_label: CSM009
        - vendor_label: CSM010
      C1E:
        vendor_label: PMS006
      CPU_Power_and_Performance_Policy:
        vendor_label: PMS00A
      Configurable_TDP_Level:
        vendor_label: PMS011
. . .
```

Just run:

```
$ ansible-playbook main.yaml -i /opt/bmc-vendor-inventories --tags get-current-values
TASK [New Generate Inventories path] ************************************************
ok: [zt_sno3 -> localhost] => {
    "msg": "Find the auto-generate inventory at /tmp/generated-inventory-oii3sql8/192.168.10.30-vendor-bios-attributes.yaml"
}
```

And then, you will get a file for each system listed in your inventory showing its current BIOS attribute value along with JSON schema related info:

```
vendor_for_192_168_10_30_system:
  vars:
    bios_attributes:
      Boot_Mode:
      - bios_schema_readonly:
          AttributeName: CSM007
          DefaultValue: UEFI
          DisplayName: Network
          HelpText: Controls the execution of UEFI and Legacy Network OpROM
          ReadOnly: false
          ResetRequired: true
          Type: Enumeration
          UefiNamespaceId: x-UEFI-AMI
          Value:
          - ValueDisplayName: UEFI
            ValueName: UEFI
          - ValueDisplayName: Legacy
            ValueName: Legacy
        value: UEFI
        vendor_label: CSM007
. . .
        value: UEFI
        vendor_label: CSM010
      C1E:
        bios_schema_readonly:
          AttributeName: PMS006
          DefaultValue: Disable
          DisplayName: Enhanced Halt State (C1E)
          HelpText: Core C1E auto promotion Control. Takes effect after reboot.
          ReadOnly: false
          ResetRequired: true
          Type: Enumeration
          UefiNamespaceId: x-UEFI-AMI
          Value:
          - ValueDisplayName: Disable
            ValueName: Disable
          - ValueDisplayName: Enable
            ValueName: Enable
        value: Disable
        vendor_label: PMS006
      CPU_Power_and_Performance_Policy:
. . .

```

> **WARNING**: make sure you set the `bios_attributes` variable correctly for your server group:
> ```
> $ cat /opt/bmc-vendor-inventories/proteus_zt_systems-bmc-hosts.yaml
> all:
>   children:
>     bmc:
>       children:
>         proteus_zt_systems:
> ...
>
> $ cat /opt/bmc-vendor-inventories/proteus_zt_systems-bios-attributes.yaml
> proteus_zt_systems:
>   vars:
>     bios_attributes:
> ```
>
> Otherwise you will get an error like this:
>
> ```
> TASK [Get the value for each defined BIOS attributes in the inventory] > *****
> fatal: [zt_sno3 -> localhost]: FAILED! => {"msg": "The task includes an option with an undefined variable. ...: {{bios_attributes}}:
> 'bios_attributes' is undefined. 'bios_attributes' is undefined.
> {{bios_attributes}}: 'bios_attributes' is undefined.
> ```


In case any `vendor_label` set is not available or does not exist, it will be notified accordingly:

```
vendor_for_192_168_10_30_system:
  vars:
    bios_attributes:
      Boot_Mode:
      - bios_schema_readonly:
          AttributeName: CSM007
          . . .
        value: UEFI
        vendor_label: CSM007
      - value: UNDEFINED                                              # <- This vendor_label wasn't found...
        vendor_label: CSM_Typo_008_NOT_FOUND_PLEASE_CHECK_BIOS_SCHEMA # <- ... in the JSON schema
      - bios_schema_readonly:
          AttributeName: CSM009
          . . .
      C1E:
        value: UNDEFINED                                                     # <- This vendor_label wasn't found...
        vendor_label: Fake_or_wrong_label_NOT_FOUND_PLEASE_CHECK_BIOS_SCHEMA # <- ... in the JSON schema
      CPU_Power_and_Performance_Policy:
. . .
```

It is recommended that if you are using a fleet of identical hardware-related systems, you run these command against just one of then (comment all but just one of them in your inventory hosts file) and use it to tune the expected BIOS attribute values. Once you are fine with the values you set, just use them as your fleet inventory:

For instances; having all your systems grouped by `proteus_zt_systems` label...

```
all:
  children:
    bmc:
      children:
        proteus_zt_systems:
          hosts:
            zt_sno1:
              bmc_host: 192.168.10.10
            zt_sno2:
              bmc_host: 192.168.10.20
            zt_sno3:
              bmc_host: 192.168.10.30
. . .
            zt_snoN:
              bmc_host: 192.168.10.NN
```

... just update the _template_ system inventory label from:

```
vendor_for_192_168_10_30_system:
  vars:
    bios_attributes:
      Boot_Mode:
. . .
```

to:

```
proteus_zt_systems:
  vars:
    bios_attributes:
      Boot_Mode:
. . .
```

to indicate that these BIOS attributes are to be validate against `proteus_zt_systems` inventory group (all your fleet of servers).

Additionally, it is possible to speed up the command by using `schemas_folder` parameter and also indicates the directory path where you want to dump the auto generate inventoy from remote system using `inventory_folder` parameter (both optionals):

```
$ ansible-playbook main.yaml -i /opt/bmc-vendor-inventories --tags get-current-values --extra-vars 'schemas_folder=/opt/json_schemas inventory_folder=/opt/inventories-with-remote-values'
TASK [New Generate Inventories path] ************************************************
ok: [zt_sno3 -> localhost] => {
    "msg": "Find the auto-generate inventory at /opt/inventories-with-remote-values/192.168.10.30-vendor-bios-attributes.yaml"
}
```

## Verify local inventory BIOS attributes against remote values

Once we have all in place, we can use our local inventory to validate the remote BIOS attributes in our fleet by simply running:

> **Note**: `schemas_folder` parameter is optional but it is hightly recommended to use it here as it uses local saved JSON schemas file as cache instead of fetching it over the network for each system in our fleet. However, it is necessary to create references for each system (_To be improved_).
>
> ```
> $ for i in {10..29}; do \
>   ln \
>     /opt/json_schemas/192.168.10.30-vendor-bios-json-schema.yaml \
>     /opt/json_schemas/192.168.10.${i}-vendor-bios-json-schema.yaml ; \
> done
> ```

```
$ ansible-playbook main.yaml -i /opt/bmc-vendor-inventories --tags verify-values --extra-vars schemas_folder=/opt/json_schemas
TASK [Inventories verification results] **************************************************************************************
ok: [zt_sno1 -> localhost] => {
    "msg": [
        "Find the verification report at /tmp/generated-inventory-mismatches-p34hfsd2r/192.168.10.10-vendor-verification-results-bios-attributes.yaml"
    ]
}
ok: [zt_sno2 -> localhost] => {
    "msg": [
        "Find the verification report at /tmp/generated-inventory-mismatches-p14nytgf/192.168.10.20-vendor-verification-results-bios-attributes.yaml"
    ]
}
ok: [zt_sno3 -> localhost] => {
    "msg": [
        "Find the verification report at /tmp/generated-inventory-mismatches-p34hntg7/192.168.10.30-vendor-verification-results-bios-attributes.yaml"
    ]
}
ok: [zt_sno4 -> localhost] => {
    "msg": [
        "Find the verification report at /tmp/generated-inventory-mismatches-d4363j5y/192.168.10.40-vendor-verification-results-bios-attributes.yaml"
    ]
}
. . .
```

If all BIOS attributes match the local inventory, you will see:

```
$ cat /tmp/generated-inventory-mismatches-p34hntg7/192.168.10.30-vendor-verification-results-bios-attributes.yaml
verification:
  message: All BIOS attribute values are the expected
  result: OK
```

If not, you will get a report with the issue:

```
verification:
  mismatches:
    Boot_Mode:
    - schema:
        AttributeName: CSM007
        DefaultValue: UEFI
        DisplayName: Network
        HelpText: Controls the execution of UEFI and Legacy Network OpROM
        ReadOnly: false
        ResetRequired: true
        Type: Enumeration
        UefiNamespaceId: x-UEFI-AMI
        Value:
        - ValueDisplayName: UEFI
          ValueName: UEFI
        - ValueDisplayName: Legacy
          ValueName: Legacy
      value_get_from_remote_bios: Legacy # <--- See the problem...
      value_set_in_local_invenroty: UEFI # <--- ... here
      vendor_label: CSM007
    CPU_Power_and_Performance_Policy:
      schema:
        AttributeName: PMS00A
        DefaultValue: Performance
        DisplayName: ENERGY_PERF_BIAS_CFG mode
        HelpText: Use input from ENERGY_PERF_BIAS_CONFIG mode selection. PERF/Balanced
          Perf/Balanced Power/Power
        ReadOnly: false
        ResetRequired: true
        Type: Enumeration
        UefiNamespaceId: x-UEFI-AMI
        Value:
        - ValueDisplayName: Performance
          ValueName: Performance
        - ValueDisplayName: Balanced Performance
          ValueName: Balanced Performance
        - ValueDisplayName: Balanced Power
          ValueName: Balanced Power
        - ValueDisplayName: Power
          ValueName: Power
      value_get_from_remote_bios: Balanced Power # <--- This is another...
      value_set_in_local_invenroty: Performance  # <--- ... detected the mismatch
      vendor_label: PMS00A
  result: FAILED
```

Notice that JSON schema is appended to ease to find the right value.

> **Note**: The current implementation does not check either the types or the values to see if they are valid as indicated by the JSON schema. However, such validation is subsequently performed by the Redfish service if an attempt is made to set an attribute with an incorrect value.

## Reconcile local inventory BIOS attributes by updating remote values

Finally, to help make it easier to reconcile all the systems in our fleet with the local inventory, simply run:

```
$ ansible-playbook main.yaml -i /opt/bmc-vendor-inventories --tags reconcile-bios-values --extra-vars schemas_folder=/opt/json_schemas
```

By default, the command re-validates our local inventory against the fleet of servers, but it is possible to skip the check, indicating it by means of the `skip_inventory_verification` parameter:

```
$ ansible-playbook main.yaml -i /opt/bmc-vendor-inventories --tags reconcile-bios-values --extra-vars 'schemas_folder=/opt/json_schemas skip_inventory_verification=yes'
```

> **Nota**: a `resource_id` optional parameter indicates ID of the System, Manager or Chassis to modify. It can be specified when more than one is listed for a particular BMC. If nothing is specified, the first one in the default list is taken, which is usually the only one in most cases.

To find out the list of the `resource_id` values, run:

```
$ ansible -m community.general.redfish_info -a 'baseuri=10.20.30.40 username=${USER} password=${PASS} category=Systems command=GetBiosAttributes'
localhost | SUCCESS => {
    "changed": false,
    "redfish_facts": {
        "bios_attribute": {
            "entries": [
                [
                    {
                        "system_uri": "/redfish/v1/Systems/System.Embedded.1" # <--- This would be the default resource_id value for this system
                    },
                    {
                        "AcPwrRcvry": "Last",
                        "AdddcSetting": "Disabled",
                        "AesNi": "Enabled",
                        "AssetTag": "",
                        "AuthorizeDeviceFirmware": "Disabled",
```

Or use `show-current-values` command:

```
$ ansible-playbook main.yaml -i /opt/bmc-vendor-inventories --tags show-current-values
ok: [zt_sno3 -> localhost] => {
    "msg": {
        "changed": false,
        "failed": false,
        "redfish_facts": {
            "bios_attribute": {
                "entries": [
                    [
                        {
                            "system_uri": "/redfish/v1/Systems/Self" # <--- This would be the default resource_id value for this system
                        },
                        {
                            "ACPI002": false,
                            "ACPI004": false,
```

As a result, the differences obtained between before and after reconciliation are shown.

> **WARNING**: this last command performs changes in your BIOS attributes. It is recommended to test this command with a training system before you run it against a bunch of servers at the same time.
