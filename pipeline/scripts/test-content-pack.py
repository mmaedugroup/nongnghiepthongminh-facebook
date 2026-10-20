#!/usr/bin/env python3
"""Dependency-free smoke tests for the content-pack.v1 contract."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
schema = json.loads((ROOT / 'pipeline/content-pack.v1.schema.json').read_text())
required = set(schema['required'])

valid = {
    'title': 'Tưới nhỏ giọt',
    'body': 'Một bản nháp thử nghiệm.',
    'pillar': 'meo_ap_dung_ngay',
    'claims': [{'text': 'Claim có nguồn', 'source': 'https://example.invalid/source'}],
    'uncertainties': [],
    'safety_note': 'Cần thử nghiệm theo điều kiện địa phương.',
    'hashtags': ['#nongnghiep', '#tudonghoa'],
    'source_url': 'https://example.invalid/source',
}
assert required <= valid.keys()
assert valid['pillar'] in schema['properties']['pillar']['enum']
assert all(tag.startswith('#') and len(tag) > 1 for tag in valid['hashtags'])

invalid = dict(valid)
invalid.pop('source_url')
assert not required <= invalid.keys()
invalid_pillar = dict(valid, pillar='unknown')
assert invalid_pillar['pillar'] not in schema['properties']['pillar']['enum']

print('content pack tests passed (valid + required-field + pillar cases)')
