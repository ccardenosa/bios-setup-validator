# checks_test.py

from unittest import TestCase
from jinja2 import Environment, FileSystemLoader

import json
import yaml

def test_validate_bios_attribute_names():

    data = [
        {
            'vendor': 'dell',
            'json_schema_yaml': 'tests/data/dell-vendor-bios-json-schema.yaml',
            'bios_attributes_yaml': 'tests/data/dell-vendor-bios-attributes.yaml',
            'verification_results': 'tests/data/dell-vendor-verification-results.yaml',
        },
        {
            'vendor': 'zt_systems',
            'json_schema_yaml': 'tests/data/zt-systems-vendor-bios-json-schema.yaml',
            'bios_attributes_yaml': 'tests/data/zt-systems-vendor-bios-attributes.yaml',
            'verification_results': 'tests/data/zt-systems-vendor-verification-results.yaml',
        },
    ]

    ctx = {
        'verification': {
            'result': 'OK',
            'message': 'The vendor labels in your inventory are correct'
            }
        }

    for item in data:

        with open(item['json_schema_yaml'], 'r') as stream:
            schema = yaml.safe_load(stream)

        with open(item['bios_attributes_yaml'], 'r') as stream:
            bios_attributes = yaml.safe_load(stream)

        j2_template="""
            {%- import 'utils.j2' as utils -%}
            {%- import 'checks.j2' as checks -%}
            {%- set bios_schema = utils.generate_dict_from_list(bios_attributes_json_schema, key='AttributeName') -%}
            {{ checks.is_vendor_label_and_value_defined_and_have_a_valid_attribute_name(ctx, bios_schema, setup_bios_attributes) }}"""

        env = Environment(loader=FileSystemLoader('playbooks/templates/'))
        t = env.from_string(j2_template)
        result = t.render(ctx=ctx, bios_attributes_json_schema=schema,
                          setup_bios_attributes=bios_attributes[item['vendor']]['vars']['bios_attributes'])
        result_dict = json.loads(result.replace("'", "\"").replace('None', 'null'))

        with open(item['verification_results'], 'r') as stream:
            verification_results = yaml.safe_load(stream)

        assert result_dict == verification_results

        # Uncomment these lines if you want to overwrite the verification files
        # with open(item['verification_results'], 'w') as stream:
        #     yaml.safe_dump(result_dict, stream)
