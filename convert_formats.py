#!/usr/bin/env python3
"""Convert all Godot 3.x format=2 to Godot 4.x format=3"""

import os
import re
from pathlib import Path

def convert_file(filepath):
    """Convert a single file from format=2 to format=3"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Convert format=2 to format=3
        if 'format=2' in content:
            # For .tscn files, add uid if not present
            if filepath.endswith('.tscn'):
                # Replace format=2 with format=3 and add uid
                if 'uid=' not in content:
                    content = re.sub(
                        r'\[gd_scene([^\]]*?)format=2\]',
                        r'[gd_scene\1format=3 uid="uid://godot46migration"]',
                        content
                    )
                else:
                    content = content.replace('format=2', 'format=3')
            else:
                # For .tres files, just replace format=2 with format=3
                content = content.replace('format=2', 'format=3')
        
        # Write back if changed
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

# Find and convert all .tscn and .tres files
root = Path('/workspaces/GoDAW')
converted_count = 0
checked_count = 0

for pattern in ['**/*.tscn', '**/*.tres']:
    for filepath in root.glob(pattern):
        # Skip test files
        if 'test' in str(filepath) or '.import' in str(filepath):
            continue
        
        checked_count += 1
        if convert_file(str(filepath)):
            converted_count += 1
            print(f"✓ Converted: {filepath.relative_to(root)}")

print(f"\n=== Conversion Summary ===")
print(f"Checked: {checked_count} files")
print(f"Converted: {converted_count} files")
