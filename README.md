# Low Latency BIOS configuration and validation

> **DISCLAIMER**
>
> As a proof of concept, at the following [link](/playbooks) you can find an implementation of the Ansible playbooks that have been used as support.
>
> Please, note this is only a teaching tool and is **not supported by Red Hat at all**.

# Abstract

The correct configuration of the hardware where the workloads of the different network functions are to be executed is crucial to achieve low latency systems. Most of this configuration is done through the system BIOS attributes. Once we have understood the function and impact of these attributes in our particular case (i.e., what would be the most appropriate values of these attributes to minimize the latency of our system), the next question is to transfer these values to each particular vendor.

The aim of this article is helping to solve these two problems as much as possible.

# Table of Contents

1. [Introduction](#introduction)
1. [BIOS attributes](#bios-attributes)
1. [What name has your vendor given to each BIOS attribute?](#what-name-has-your-vendor-given-to-each-bios-attribute)
1. [Validate BIOS attribute values](#validate-bios-attribute-values)
1. [Conclusion](#conclusion)

# Introduction

In 5G networks, low response times or low latency are essential to [meet the expected requirements](https://broadbandlibrary.com/5g-low-latency-requirements/). This necessarily implies the use of systems where the response time is predictable, as well known as Realtime systems. For the case of [low latency tuning in Openshift](https://docs.openshift.com/container-platform/4.13/scalability_and_performance/cnf-low-latency-tuning.html) we have the [RT_Preempt patch](https://cdn.kernel.org/pub/linux/kernel/projects/rt/) for linux Kernel, where a very good approximation to a real time system is achieved.

Although having at our disposal a kernel that can be interrupted by a higher priority task allows a greater control of its response time, there is another factor even more impacting to have low latency systems. Actually it is beyond the control of the kernel itself, since its staging depends on the hardware where our software is running (kernel included).

The **BIOS** (Basic Input/Output System) is the mechanism through which we can adjust our hardware to meet the expected latency requirements.

In this article we will see:

- What are the BIOS attributes to pay attention to for the Telco case.
- How to find out what that field is named for the corresponding vendor.
- How to know what values are set and,
- How to configure it with the appropriate values.
- Finally we will show how to validate that our configuration is correct.

# BIOS attributes

In the official Openshift doc we can find [a detailed table](https://docs.openshift.com/container-platform/4.13/scalability_and_performance/ztp_far_edge/ztp-vdu-validating-cluster-tuning.html#ztp-du-firmware-config-reference_vdu-config-ref) of all the BIOS attributes on which we can act to achieve the best performance of our cluster in terms of latency.

These attributes basically govern how the hardware should manage the use of power supply, clock frequencies or the use of the buses and cache lines involved in the different architectures. So, understanding each of these technologies can help us determine the best value for our case.

## vDU Configuration Reference Settings

Distributed unit (DU) hosts require the BIOS to be configured before the host can be provisioned. The BIOS configuration is dependent on the specific hardware that runs your DUs and the particular requirements of your installation.

> **Note**: At the time of writing this article, some vendors offer specific profiles for low latency environments and, specifically, for both Dell and HPe we can find a Telco Low Latency profile in the latest available versions of their BIOS.
>
> If this is the case for the hardware you intend to use, the use of such profiles is absolutely recommended over manual settings.
>
> The way to use such profiles is analogous to any other BIOS attribute.


So, its configuration depends on your specific hardware and network requirements. However, having a clear idea of each of the technologies offered by your hardware will be of great help when determining which are the values that best suit your use case:

| OCP BIOS Common Settings | Sample Values | Description |
|--------------------------|---------------|-------------|
| Workload Profile | If available always use TelcoOptimizedProfile over manual configuration | Select this option to change the Workload Profile to accommodate your desired workload.<br/><br/>The values taken by each BIOS attribute will depend on its particular vendor. |
| [HyperThreading](https://www.intel.com/content/www/us/en/gaming/resources/hyper-threading.html) (HT) | Enabled | Hyper-Threading Technology is a hardware innovation that allows more than one thread to run on each core. More threads means more work can be done in parallel.<br/><br/>When HT Technology is active, the CPU exposes two execution contexts per physical core. This means that one physical core now works like two “logical cores” that can handle different software threads.<br/><br/> By taking advantage of idle time when the core would formerly be waiting for other tasks to complete, HT Technology improves CPU throughput (by up to 30% in server applications).<br/><br/>Note however that, for some use cases, this technology could pose a performance penalty, since if unrelated processes make use of shared resources within said core, it could be the case that the penalty for cache misses outweigh the gain of having these additional virtual cores.|
| [HyperTransport](https://en.wikipedia.org/wiki/HyperTransport) (HT) | Enabled | It is a bus technology developed by AMD. HT provides a high-speed link between the components in the host memory and other system peripherals. |
| BootMode | UEFI | Determines whether the BIOS attempts to boot the OS via the method defined by the Unified Extensible Firmware Interface (UEFI) specification or via the legacy (BIOS) method.<br/><br/>Selecting BIOS Legacy ensures compatibility with older operating systems that do not support the UEFI method.<br/><br/>Many newer operating systems are UEFI-aware, and some of them may also support legacy boot methods. |
| [CPU Power and Performance Policy](https://techlibrary.hpe.com/docs/iss/proliant_uefi/UEFI_Edgeline_103117/GUID-D7147C7F-2016-0901-0A69-000000000BC2.html) | Performance (or Maximum Performance) | **Maximum Performance** — Provides the highest performance and lowest latency. Use this setting for environments that are not sensitive to power consumption.<br/><br/>**Balanced Performance** — Provides optimum power efficiency and is recommended for most environments.<br/><br/>**Balanced Power** — Provides optimum power efficiency based on server utilization.<br/><br/>**Power Savings Mode** — Provides power savings for environments that are power sensitive and can accept reduced performance. |
| [Uncore Frequency Scaling](https://www.kernel.org/doc/html/latest/admin-guide/pm/intel_uncore_frequency_scaling.html) | Disabled | "[Uncore](https://en.wikipedia.org/wiki/Uncore)" is a term used by Intel to describe the functions of a microprocessor that are not in the core, but which must be closely connected to the core to achieve high performance.<br/><br/>The core contains the components of the processor involved in executing instructions, including the [ALU](https://en.wikipedia.org/wiki/Arithmetic_logic_unit), [FPU](https://en.wikipedia.org/wiki/Floating_point_unit), [L1](https://en.wikipedia.org/wiki/L1_cache) and [L2](https://en.wikipedia.org/wiki/L2_cache) cache.<br/><br/>Uncore functions include [QPI](https://en.wikipedia.org/wiki/Intel_QuickPath_Interconnect) controllers, [L3 cache](https://en.wikipedia.org/wiki/L3_cache), [snoop agent](https://en.wikipedia.org/wiki/Memory_coherence) [pipeline](https://en.wikipedia.org/wiki/Instruction_pipeline), on-die [memory controller](https://en.wikipedia.org/wiki/Memory_controller), on-die [PCI Express Root Complex](https://en.wikipedia.org/wiki/PCI_Express_Root_Complex), and [Thunderbolt controller](https://en.wikipedia.org/wiki/Thunderbolt_(interface)).<br/><br/>Use the _Uncore Frequency Scaling_ option to control the frequency scaling of the processor's internal busses. |
| [Uncore](https://en.wikipedia.org/wiki/Uncore) Frequency | Maximum | Uncore frequency is the frequency of the non-core parts of the CPU, ie cache, memory controller, etc. It's also known as ringbus frequency. |
| Performance P-limit | Enabled | _Package C-state limit_ <br/><br/>It allows the processor to enter lower power states when idle.<br/><br/>When set to Enabled (OS controlled) or when set to Autonomous (if Hardware controlled is supported), the processor can operate in all available Power States to save power, but may increase memory latency and frequency jitter. |
| [Enhanced Intel SpeedStep (R) Tech (aka P-States)](https://edc.intel.com/content/www/us/en/design/ipla/software-development-platforms/client/platforms/alder-lake-desktop/12th-generation-intel-core-processors-datasheet-volume-1-of-2/006/enhanced-intel-speedstep-technology_1/) | Enabled | [Power Management States: What is a S-state and a P-state?](https://www.techjunkie.com/power-management-states-s-state-p-state/)<br/><br/>Not all processor manufacturers refer to a performance state as a P-state. Intel actually calls it SpeedStep (though this trademark expired in 2012), but AMD might call them PowerNow! or Cool’n’Quiet in their processors. SpeedStep (and other brands’ similar implementations) is, in essence, a way to dynamically scale the processor’s P-states through software. |
| [Intel(R) Turbo Boost Technology](https://edc.intel.com/content/www/us/en/design/ipla/software-development-platforms/client/platforms/alder-lake-desktop/12th-generation-intel-core-processors-datasheet-volume-1-of-2/006/intel-turbo-boost-technology-2-0/) | Disabled in NFV deployments that require deterministic performance.<br/><br/>Enabled in all other scenarios. | It allows the processor to opportunistically increase a set of CPU cores higher than the CPU’s rated base clock speed based on the number of active cores, power and thermal headroom in a system.<br/><br/>It is important to understand that **this is not a guarantee of a CPU frequency increase**, rather it is enabling the opportunity to run at a higher clock frequency.<br/><br/>The performance of Turbo Mode increases when fewer cores are active, dynamic power management is enabled, and the system is running below the thermal design limits for the platform.<br/><br/>The Intel® Turbo Boost Technology 2.0 allows the processor core to opportunistically and automatically run faster than the processor core base frequency if it is operating below power, temperature, and current limits. This feature is designed to increase the performance of both multi-threaded and single-threaded workloads.<br/><br/>It increases the ratio of application power towards Processor Base Power (a.k.a TDP) and also allows to increase power above Processor Base Power (a.k.a TDP) as high as PL2 for short periods of time. Thus, thermal solutions and platform cooling that are designed to less than thermal design guidance might experience thermal and performance issues since more applications will tend to run at the maximum power limit for significant periods of time. |
| Intel Configurable [TDP](https://www.intel.com/content/www/us/en/support/articles/000055611/processors.html) (Processor Base Power) | Enabled | Enables Thermal Design Power (TDP) for the CPU (See next one). |
| Configurable TDP (Processor Base Power) Level | Level 2 | Allows the reconfiguration of the processor Thermal Design Power (TDP) levels based on the power and thermal delivery capabilities of the system.<br/><br/>TDP refers to the maximum amount of power the cooling system is required to dissipate.<br/><br/>**NOTE:** This option is only available on certain [SKUs of the processors](https://www.intel.com/content/www/us/en/processors/processor-numbers.html), and the number of alternative levels varies as well. |
| Energy Efficient Turbo | Disabled | When Energy Efficient Turbo is enabled, the CPU’s optimal turbo frequency will be tuned dynamically based on CPU utilization.<br/><br/>The actual turbo frequency the CPU is set to is proportionally adjusted based on the duration of the turbo request.<br/><br/>Memory usage of the OS is also monitored. If the OS is using memory heavily and the CPU core performance is limited by the available memory resources, the turbo frequency will be reduced until more memory load dissipates and more memory resources become available.<br/><br/>The power/performance bias setting also influences energy efficient turbo.<br/><br/>Energy Efficient Turbo is best used when **attempting to maximize power consumption over performance**. |
| Hardware P-States | Disabled | **Disable** — Hardware chooses a P-state based on OS Request (Legacy P-States)<br/><br/>**Native Mode** — Hardware chooses a P-state based on OS guidance  Out of Band<br/><br/>**Mode** — Hardware autonomously chooses a P-state (no OS guidance) |
| [Package C-State](https://www.dell.com/support/kbdoc/en-us/000060621/what-is-the-c-state) | C0/C1 state | In order to save energy when the CPU is idle, you can command the CPU to enter a low-power mode.<br/><br/>Each CPU has several power modes, which are collectively called _C-states_ or _C-modes_. |
| C1E | Disabled | C1 Enhanced mode (C1E) is a processor power saving feature that halts cores not in use and maintains cache coherency.<br/><br/>C1E maintains all of the C1 halt state functionality, but the core voltage is reduced for enhanced power savings.<br/><br/>If all cores in a package are in C1 state, the package itself will enter C1E unless C1E is disabled.<br/><br/>C1E can help to provide power savings in those circumstances where cache coherency is paramount. Those applications which thread well and can maintain utilization of processor cores (virtualization, HPC and database workloads) do not benefit and under certain circumstances may be hindered by C1E.<br/><br/>If a user is attempting to achieve maximum opportunity for Turbo Mode to engage, C1E is recommended. C1E is not recommended for latency sensitive workloads. |
| Processor C6 | Disabled | The C6 state is a power-saving halt and sleep state that a CPU can enter when it is not busy.<br/><br/>It can take some time for the CPU to leave these states and return to a running condition. So **If you are concerned about performance** (for all but latency-sensitive single-threaded applications), and if you can do so, **disable anything related to C-states**.<br/><br/>You can specify whether the BIOS sends the C6 report to the operating system. When the OS receives the report, it can transition the processor into the lower C6 power state to decrease energy use while maintaining optimal processor performance.<br/><br/>The setting can be either of the following:<br/><br/>**Disabled** — The BIOS does not send the C6 report.<br/>**Enabled** — The BIOS sends the C6 report, allowing the OS to transition the processor to the C6 low-power state. |
| Sub NUMA Cluster ([SNC](https://www.intel.com/content/www/us/en/developer/articles/technical/xeon-processor-scalable-family-technical-overview.html)) |  Disabled | SNC (Processor Sub-NUMA Clustering) partitions Intel Xeon Scalable processor cores and last-level cache (LLC) into disjoint clusters with each cluster bound to a set of memory controllers in the system. SNC improves average latency to the LLC and memory.<br/><br/>For a multi-socketed system, all SNC clusters are mapped to unique NUMA domains.|

Now that we know the meaning behind each attribute, it will be easier to determine which is the most appropriate value for our particular case.

# What name has your vendor given to each BIOS attribute?

Unfortunately, there is no standard or consensus on the naming of each vendor's BIOS attributes. So the first task at hand will be to determine if a vendor supports certain functionality and, if so, what is the attribute in their BIOS that controls that functionality.

## Discovering attribute names

For the first of our tasks, we are going to make use of the Redfish support that vendors add to their BMCs.

> **Note**: A [baseboard management controller](https://www.servethehome.com/explaining-the-baseboard-management-controller-or-bmc-in-servers/) (BMC) is a small computer that sits on virtually every server motherboard. It is used in servers to perform the tasks that an administrator would otherwise need to physically visit the racked server to accomplish. This way a remote server can be configured remotely connecting to the webserver running into BMC.

> **Note**: [Redfish](https://www.dmtf.org/standards/redfish) defines a RESTful API to handle all the hardware actions and settings available through the BMC in a consistent manner (a key feature in _FarEdge_ environments).

To find out if a feature is supported or not by a certain provider and how it has been labeled in its particular case, we can extract the information from all the BIOS attributes available for our provider, using the following script:

```
$ cat << EOF > get-bios-attribute-definitions.sh
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
EOF
```

If we execute this script against, for example, the _iDrac_ (BMC) of a _Dell PowerEdge R750_, and we want to know if the BIOS supports `Hyper-Threading` and how it is configured, we will have:

```
  {
    	"AttributeName": "LogicalProc",
    	"CurrentValue": null,
    	"DisplayName": "Logical Processor",
    	"DisplayOrder": 5800,
    	"HelpText": "Each processor core supports up to two logical
		 processors. When set to Enabled, the BIOS reports all logical
		 processors. When set to Disabled, the BIOS only reports one
		 logical processor per core.	Generally, higher processor
		 count results in increased performance for most multi-threaded
		 workloads and the recommendation is to keep this enabled.
		 However, there are some floating point/scientific workloads,
		 including HPC workloads, where disabling this feature may
		 result in higher performance.",
    	"Hidden": false,
    	"Immutable": false,
    	"MenuPath": "./ProcSettingsRef",
    	"ReadOnly": false,
    	"ResetRequired": true,
    	"Type": "Enumeration",
    	"Value": [
      	  {
        	"ValueDisplayName": "Enabled",
        	"ValueName": "Enabled"
      	  },
      	  {
        	"ValueDisplayName": "Disabled",
        	"ValueName": "Disabled"
          }
    	],
    	"WarningText": null,
    	"WriteOnly": false
  },
```
As we can see, each BIOS attribute schema includes (not all are shown in this example):
- The attribute name this vendor uses.
- Type of each BIOS attribute (enum, string, numeric, or Boolean).
- Possible values for enum type attributes.
- Display strings for the attributes and their possible values.
- Help text and warning text.
- Location and display order information, including menu hierarchy for an attribute.
- Value limits, including maximum, minimum, and step values for numeric attributes, and minimum and maximum character lengths, as well as regular expressions for string attributes.
- And other meta-data.

Comparing same info with _Proteus I_Mix ZT-SYSTEMS_ system vendor, we have:

```
  {
	"DefaultValue": "Enable",
	"UefiNamespaceId": "x-UEFI-AMI",
	"DisplayName": "Hyper-Threading [ALL]",
	"HelpText": "Enables Hyper Threading (Software Method to Enable/
	Disable Logical Processor threads.",
	"AttributeName": "PRSS011",
	"Value": [
  	  {
    	    "ValueName": "Disable",
    	    "ValueDisplayName": "Disable"
  	  },
  	  {
    	    "ValueName": "Enable",
    	    "ValueDisplayName": "Enable"
  	  }
	],
	"ReadOnly": false,
	"ResetRequired": true,
	"Type": "Enumeration"
  },
```

## BIOS attributes by vendor

Since the BIOS attributes are directly linked to the architecture we use, which in turn depends on the selected vendor, the task of configuring our vDU taking into account [the recommended attributes](https://docs.openshift.com/container-platform/4.13/scalability_and_performance/ztp_far_edge/ztp-vdu-validating-cluster-tuning.html#ztp-du-firmware-config-reference_vdu-config-ref) will not be easy, since the denomination of such attribute could change (be labeled with another name) or there may not even be such technology in the hardware we are going to use.
In the previous example we have that while **Dell** tags this attribute as `LogicalProc`, **ZT-SYSTEMS** uses `PRSS011`.

The following comparative table shows how the same attributes are identified for 4 different vendors. As can be seen, in some cases, the functionality does not exist (or could not be determined at the time of writing this article):

| BIOS attribute | Dell Attribute Name | ZT Systems Attribute Name | HPE Attribute Name | SuperMicro Attribute Name |
|----------------|---------------------|---------------------------|--------------------|---------------------------|
| Workload Profile | WorkloadProfile | | WorkloadProfile |
| HyperThreading (HT) | LogicalProc | PRSS011 | ProcHyperthreading | Hyper-Threading[ALL] |
| HyperTransport (HT) | | | | |
| BootMode | BootMode | CSM007<br/>CSM008<br/>CSM009<br/>CSM010 | BootMode | Bootmodeselect |
| CPU Power and Performance Policy | ProcPwrPerf | PMS00A | | ENERGY_PERF_BIAS_CFGmode |
| Uncore Frequency Scaling | CpuInterconnectBusLinkPower | PMS014 | | |
| Uncore Frequency | UncoreFrequency | KTIS001 | UncoreFreqScaling | |
| Performance P-limit | ProcCStates | | | |
| Enhanced Intel SpeedStep (R) Tech (aka P-States) | | PMS001 | | SpeedStep(P-States) |
| Intel Configurable TDP | | | | |
| Configurable TDP Level | ProcConfigTdp | PMS011 | | ConfigTDP |
| Intel(R) Turbo Boost Technology | | PMS002 | ProcTurbo | TurboMode |
| Energy Efficient Turbo | | PMS01A | | |
| Hardware P-States | CollaborativeCpuPerfCtrl | PMS003 | | HardwareP-States |
| Package C-State | | PMS007 | | PackageCState |
| C1E | ProcC1E | PMS006 | | EnhancedHaltState(C1E) |
| Processor C6 | | PMS005 | | CPUC6report |
| Sub NUMA Cluster | SubNumaCluster | | SubNumaClustering | SNC |

# Validate BIOS attribute values

One way to check that the values of our BIOS attributes are as expected would be to ask our Redfish service to show us the current values and check that they are correct.

## Getting the current BIOS attribute values for your system

Running the following script displays the value of all BIOS attributes of a system via Redfish:

```
$ cat << EOF > get-current-bios-attribute-values.sh
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
EOF
```

Comparing two providers, we can see the different denominations for the BIOS attributes:

```
$ BMC_HOST="dell_host" \
  BMC_USER="..." \
  BMC_PASS="xxxxx" \
  bash get-current-bios-attribute-values.sh
. . .
  "AcPwrRcvryUserDelay": 60,
  "LogicalProc": "Enabled",
  "CpuInterconnectBusSpeed": "MaxDataRate",
. . .

$ BMC_HOST="zt-systems_host" \
  BMC_USER="..." \
  BMC_PASS="xxxxxx" \
  bash get-current-bios-attribute-values.sh
. . .
  "PRSS004": 0,
  "PRSS011": "Enable",
  "PRSS013": "Disable",
. . .
```

So, with these values, and using our reference table by provider, we could find out if our values are what we expect. However, this approximation does not seem very adequate as it is error prone and unaffordable when the number of systems to be covered is large.

## Automatic BIOS attribute validation

A much better approach is to use the advantages that technologies like [Ansible](https://www.ansible.com/) or [AAP](https://access.redhat.com/products/red-hat-ansible-automation-platform/) give us when controlling fleets of systems in an orderly and controlled way.

We can write a playbook that basically checks that the values of certain attributes of our BIOS are what we expect for a whole fleet of systems in parallel. For this, we can use the [redfish_info module](https://docs.ansible.com/ansible/latest/collections/community/general/redfish_info_module.html), which allows us to collect information about the status of the BIOS attributes:

```
$ BMC_HOST="zt-systems_host" \
  BMC_USER="..." \
  BMC_PASS="xxxxxx" \
  ansible -m community.general.redfish_info \
  -a 'baseuri=${BMC_HOST} username=${BMC_USER} password=${BMC_PASS} \
  category=Systems command=GetBiosAttributes' localhost
localhost | SUCCESS => {
	"changed": false,
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
                    	"CSM008": "UEFI",
. . .

```

The idea is simple; create an inventory for the case of our provider, where we will indicate which attributes and values are required to be configured in the BIOSes of each server. Said inventory can be kept in a Git repository and be modified and adapted without losing the history of the changes that have been made. In addition, it can be structured as best suits our needs. For example, we may have more than one vendor, as well as different groups of systems with different needs and values of their BIOS attributes.

### Create and organize an inventory

The way we organize our inventory depends on the fleet we have. But let’s say we have to cope with several vendors. We might set up our inventory this way and push it into a Git repo to track the changes we make or the new systems or vendors we add:

```
$ tree bmc-vendor-inventories
bmc-vendor-inventories
├── HP
├── dell
│   └── PowerEdge-R750
│   	└── bios-version-1.8.2
├── supermicro
└── zt-systems
	├── galene
	│   ├── bios-version-0.23
	│   ├── bios-version-0.28
	│   └── bios-version-0.29
	└── proteus
	    ├── bios-version-0.23
	    ├── bios-version-0.28
	    └── bios-version-0.29
. . .
```

Imagine we would get a bunch of brand-new ZT-Systems servers and we want to set their BIOS up all at once with the parameters suggested at the beginning of the article.

Since we want to be effective, we could write an Ansible playbook that, based on the aforementioned parameters, generates a template that we can use to create our inventory:

```
$ ansible-playbook playbooks/main.yaml \
  --tags generate-inventory-template \
  -e "inventory_folder=/opt/bmc-vendor-inventories/zt-systems \
      label_id=zt-systems"
. . .
TASK [New Generate Inventories path] ****************************************************************************************
ok: [localhost] => {
	"msg": [
    	"Find the auto-generate inventory at:",
    	"/opt/bmc-vendor-inventories/zt-systems/zt-systems-bmc-hosts.yaml",
    	"/opt/bmc-vendor-inventories/zt-systems/zt-systems-bios-attributes.yaml"
	]
}

$ tree /opt/bmc-vendor-inventories
└── zt-systems
    ├── zt-systems-bios-attributes.yaml
    └── zt-systems-bmc-hosts.yaml
. . .
```

Let’s begin with the BMCes. We basically need to set up the hostname or IP for each BMC we need our playbook check:

```
$ cat /opt/bmc-vendor-inventories/zt-systems/zt-systems-bmc-hosts.yaml
all:
  children:
    bmc:
      children:
        zt_systems:
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

```
We select one of our new-brand servers and update our inventory accordingly:

```
$ cat /opt/bmc-vendor-inventories/zt-systems/zt-systems-bmc-hosts.yaml
all:
  children:
    bmc:
      children:
        zt_systems:
          hosts:
            zt-sno3:
              bmc_host: "{{ lookup('ansible.builtin.env', 'ZT_BMC_HOST') }}"
          vars:
            bmc_password: "{{ lookup('ansible.builtin.env', 'ZT_BMC_USER') }}"
            bmc_username: "{{ lookup('ansible.builtin.env', 'ZT_BMC_PASS') }}"
```

### Figure out how vendors label BIOS attributes

At this point, we would need to fill up the BIOS attributes inventory. Actually, what we would need to do is to figure out (if it exists) what is the corresponding `vendor_label` for each of those BIOS attributes. Of course, these are just the recommended BIOS attributes at the time of writing this article. It is fine to add or delete BIOS attributes in your inventory. The only requirement is that all of them have the vendor's label correctly defined.

```
$ cat opt/bmc-vendor-inventories/zt-systems/zt-systems-bios-attributes.yaml
zt_systems:
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
```

The task of defining these labels can be tedious, but there is no other option than to access the BIOS schema and search and define these attributes as our provider has labeled them. The result of this task can be seen reflected in the [table shown above](#bios-attributes-by-vendor).

Unfortunately, there is not a comprehensive table and new versions of the BIOS may bring changes that we must be able to update. For this purpose, what we must do is to look up the attribute scheme for the BIOS of our vendor. Luckily, this information is accessible from the BMC itself via Redfish. Again, we could write a Ansible playbook to get the task done:

```
$ ansible-playbook playbooks/main.yaml \
    -i /opt/bmc-vendor-inventories/zt-systems \
    --tags get-bios-attributes-jsonschema \
    -e schemas_folder=/opt/json_schemas
. . .
TASK [New Generate JSON schema path] **********************************************************************************************
ok: [zt_sno3 -> localhost] => {
	"msg": "Find the JSON schema path at /opt/json_schemas/zt-sno3-vendor-bios-json-schema.yaml"
}

$ % head -20 /opt/json_schemas/zt-sno3-vendor-bios-json-schema.yaml
Attributes:
- AttributeName: TCG003
  DefaultValue: Enable
  DisplayName: TPM SUPPORT
  HelpText: Enables or Disables BIOS support for security device. O.S
  will not show Security Device. TCG EFI protocol and INT1A interface
  will not be  available.
  ReadOnly: false
  ResetRequired: true
  Type: Enumeration
  UefiNamespaceId: x-UEFI-AMI
  Value:
  - ValueDisplayName: Disable
    ValueName: Disable
  - ValueDisplayName: Enable
    ValueName: Enable
- AttributeName: TCG023
  DefaultValue: Disabled
  DisplayName: '  Disable Block Sid'
  HelpText: '  Override to allow SID authentication in TCG Storage
  device'
  ReadOnly: false
```

By studying the `HelpText` field we can end up determining if the attribute in question is the one we are looking for. Then, the `vendor_label` in our inventory must match the `AttributeName` field.

Therefore, our inventory would be such that:

```
$ cat opt/bmc-vendor-inventories/zt-systems/zt-systems-bios-attributes.yaml
zt_systems:
  vars:
    bios_attributes:
      HyperThreading:
        vendor_label: PRSS011
      Boot_Mode:
        - vendor_label: CSM007
        - vendor_label: CSM008
        - vendor_label: CSM009
        - vendor_label: CSM010
      HyperTransport:
      CPU_Power_and_Performance_Policy:
        vendor_label: PMS00A
      Uncore_Frequency_Scaling:
        vendor_label: PMS014
      Uncore_Frequency:
        vendor_label: KTIS001
      Performance_P_limit:
      Enhanced_Intel_SpeedStep_Tech:
        vendor_label: PMS001
      Intel_Turbo_Boost_Technology:
      Intel_Configurable_TDP:
      Configurable_TDP_Level:
        vendor_label: PMS011
      Energy_Efficient_Turbo:
        vendor_label: PMS01A
      Hardware_P_States:
        vendor_label: PMS003
      Package_C_State:
        vendor_label: PMS007
      C1E:
        vendor_label: PMS006
      Processor_C6:
        vendor_label: PMS005
      Sub_NUMA_Clustering:
        vendor_label:
```

Please, note that I have deliberately left blank those attributes that I have not been able to define (i.e.: `HyperTransport` or `Performance_P_limit`), based on the available documentation. Another thing to note is that, as you can see in the inventory, it would be interesting to group certain attributes that are related, like the `Boot_Mode` in this case.

### Get BIOS attribute current values

To simplify the task of filling in the values of each attribute, we can again write an Ansible playbook that connects to the BMC of the system that we have in our inventory and assigns the current values of each of the labels that we have defined for each attribute of the BIOS:

```
$ ansible-playbook playbooks/main.yaml \
  -i /opt/bmc-vendor-inventories/zt-systems \
  --tags get-current-values
. . .
TASK [New Generate Inventories path] ***********************************************************************************************
ok: [zt_sno3 -> localhost] => {
	"msg": "Find the auto-generate inventory at /tmp/generated-inventory-80bt9ror/zt-sno3-vendor-bios-attributes.yaml"
}

$ cat /tmp/generated-inventory-80bt9ror/zt-sno3-vendor-bios-attributes.yaml
vendor_for_zt_sno3_system:
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
      - bios_schema_readonly:
          AttributeName: CSM008
          DefaultValue: UEFI
. . .
      HyperThreading:
        bios_schema_readonly:
          AttributeName: PRSS011
          DefaultValue: Enable
          DisplayName: Hyper-Threading [ALL]
          HelpText: Enables Hyper Threading (Software Method to Enable/ Disable Logical Processor threads.
          ReadOnly: false
          ResetRequired: true
          Type: Enumeration
          UefiNamespaceId: x-UEFI-AMI
          Value:
          - ValueDisplayName: Disable
            ValueName: Disable
          - ValueDisplayName: Enable
            ValueName: Enable
        value: Enable
        vendor_label: PRSS011
      HyperTransport:
        value: UNDEFINED
        vendor_label: UNDEFINED
      Intel_Configurable_TDP:
        value: UNDEFINED
        vendor_label: UNDEFINED
      Intel_Turbo_Boost_Technology:
        value: UNDEFINED
        vendor_label: UNDEFINED
    system_details:
      BiosVersion: '0.29'
      DetailsGatheredAt: 2023-09-07_125229
      Id: Self
      Manufacturer: ZTSYSTEMS
      Model: ' '
      Name: Proteus I_Mix
      PartNumber: PA-00415-001
      SerialNumber: 20739971N009
```

As we can see, those attributes that we have not defined (or mispelled) will appear as `UNDEFINED`, so that we are aware that we may not have written them correctly or that they are not going to be used and we should remove them from our inventory. As for those that are defined, the schema is attached so that we can fully understand the values it can take. In addition, relevant information about the system used for the query is added, as can be seen under the tag `system_details `.

Once the information is analyzed, we can update our BIOS attribute values accordingly and get rid of all those attributes that are not defined:

> **Note**: both `bios_schema_readonly` and `system_details` are just for documentation purposes. We can keep them in case we need to adjust any attribute in the future.

```
$ cat opt/bmc-vendor-inventories/zt-systems/zt-systems-bios-attributes.yaml
zt_systems:
  vars:
    bios_attributes:
      HyperThreading:
        bios_schema_readonly:
          AttributeName: PRSS011
          DefaultValue: Enable
          DisplayName: Hyper-Threading [ALL]
          HelpText: Enables Hyper Threading (Software Method to Enable/Disable Logical Processor threads.
          ReadOnly: false
          ResetRequired: true
          Type: Enumeration
          UefiNamespaceId: x-UEFI-AMI
          Value:
          - ValueDisplayName: Disable
            ValueName: Disable
          - ValueDisplayName: Enable
            ValueName: Enable
        value: Enable
        vendor_label: PRSS011
      Boot_Mode:
. . .
```

### Apply new BIOS attribute values
The final step is obvious, we can write an Ansible playbook that taking our inventory, apply those new BIOS attribute values to our target system:

```
$ ansible-playbook playbooks/main.yaml \
  -i /opt/bmc-vendor-inventories/zt-systems \
  --tags reconcile-bios-values
. . .
TASK [BIOS attribute changes results report] ***********************************************************************************************
ok: [zt_sno3 -> localhost] => {
	"msg": "Find the verification report at /tmp/generated-bios-attributes-changes-xqqas87l/zt-sno3-vendor-bios-attributes.yaml"
}

$ cat /tmp/generated-bios-attributes-changes-xqqas87l/zt-sno3-vendor-bios-attributes.yaml
Modified:
  PMS006:
    new_value: Disable
    previous_value: Enable
. . .
Report_Date: 2023-08-11_142447
```

When we're happy with our changes, the next thing we need to do is apply them to our entire fleet. To do this, all we have to do is update the host inventory to add the rest of the systems we want to configure:

```
$ cat /opt/bmc-vendor-inventories/zt-systems/zt-systems-bmc-hosts.yaml
all:
  children:
    bmc:
      children:
        zt_systems:
          hosts:
            zt-sno1:
              bmc_host: "{{ lookup('ansible.builtin.env', 'ZT_BMC_HOST_1') }}"
            zt-sno2:
              bmc_host: "{{ lookup('ansible.builtin.env', 'ZT_BMC_HOST_2') }}"
            zt-sno3:
              bmc_host: "{{ lookup('ansible.builtin.env', 'ZT_BMC_HOST_3') }}"
            zt-sno4:
              bmc_host: "{{ lookup('ansible.builtin.env', 'ZT_BMC_HOST_4') }}"
          vars:
            bmc_password: "{{ lookup('ansible.builtin.env', 'ZT_BMC_USER') }}"
            bmc_username: "{{ lookup('ansible.builtin.env', 'ZT_BMC_PASS') }}"
```

And we would only have to execute the same playbook, which will now act on all the systems at the same time:

```
$ ansible-playbook playbooks/main.yaml \
  -i /opt/bmc-vendor-inventories/zt-systems \
  --tags reconcile-bios-values
. . .
```

### Validate BIOS attribute values

The other great advantage of following this method will be to be able to validate that the BIOS attributes of our servers are correctly configured.

Let's imagine that we are informed that a server from the same vendor, model and BIOS version in our inventory is suffering from performance problems. One of the first things we could quickly and easily check would be if its BIOS attributes are set correctly. To do this, we only had to create an inventory for these systems, and using the parameters that we know are correct ...

```
$ cp /opt/bmc-vendor-inventories/zt-systems/ \
     /opt/issue-investigation-bmc-vendor-inventory/

$ tree /opt/issue-investigation-bmc-vendor-inventory
└── zt-systems
    ├── zt-systems-bios-attributes.yaml
    └── zt-systems-bmc-hosts.yaml
```

... modify the host inventory to point to the buggy one:

```
$ cat /opt/issue-investigation-bmc-vendor-inventory/zt-systems-bmc-hosts.yaml
all:
  children:
    bmc:
      children:
        zt_systems:
          hosts:
            zt_system_in_troubles:
              bmc_host: "{{ lookup('ansible.builtin.env', 'ZT_ISSUE_BMC_HOST') }}"
          vars:
            bmc_password: "{{ lookup('ansible.builtin.env', 'ZT_ISSUE_BMC_USER') }}"
            bmc_username: "{{ lookup('ansible.builtin.env', 'ZT_ISSUE_BMC_PASS') }}"
```

Again, we can write an Ansible playbook that compares our local inventory BIOS attribute values to the values of the failing remote system and tells us the differences:

```
$ ansible-playbook playbooks/main.yaml \
  -i /opt/issue-investigation-bmc-vendor-inventory \
  --tags verify-values
. . .
TASK [Inventories verification results] ***********************************************************************************************
ok: [zt_sno3 -> localhost] => {
	"msg": [
    	"Find the verification report at /tmp/generated-inventory-mismatches-oswxk9bi/zt-buggy-vendor-verification-results-bios-attributes.yaml"
	]
}

$ cat /tmp/generated-inventory-mismatches-oswxk9bi/zt-buggy-vendor-verification-results-bios-attributes.yaml
verification:
  mismatches:
    CPU_Power_and_Performance_Policy:
      schema:
        AttributeName: PMS00A
        DefaultValue: Performance
        DisplayName: ENERGY_PERF_BIAS_CFG mode
        HelpText: Use input from ENERGY_PERF_BIAS_CONFIG mode selection. PERF/Balanced Perf/Balanced Power/Power
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
      value_get_from_remote_bios: Power
      value_set_in_local_invenroty: Performance
      vendor_label: PMS00A
  result: FAILED
```

And there it is: the expected values for `CPU_Power_and_Performance_Policy` BIOS attribute, labeled as `PMS00A` for ZT-Systems vendor should be `Performance`, but it seems that is set to `Power` instead, causing an unwanted increase in system response time.

# Conclusion

The previous example is illustrative of how detrimental it can be for the optimal performance of a system to configure a BIOS attribute in an inappropriate way for our use case.

Since guaranteeing the correct configuration of the BIOS attributes of our fleet of servers in the Telco field is so critical and that each vendor develops their hardware differently giving rise to different possibilities when it comes to getting the best out of systems, having a detailed knowledge of where to find the right information as well as being able to automate the configuration process to the greatest degree possible, is a must if we want to avoid many difficult-to-trace problems later.
