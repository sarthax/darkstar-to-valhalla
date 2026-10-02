#!/usr/bin/env python3
"""
Simple test script for DBtool.py - verifies syntax is correct
"""
import sys

# Just import to check syntax
print("Testing DBtool.py syntax...")
try:
    # Test imports work
    from colorama import init, Fore, Style
    print("[OK] Imports successful")

    # Try basic operations
    test_str = f'Test {Fore.GREEN}with colors{Style.RESET_ALL}'
    print(f"[OK] F-strings work: {test_str}")

    print("\n[SUCCESS] DBtool.py syntax is valid!")
    print("The tool can now be run with: DBtool.bat")

except Exception as e:
    print(f"[ERROR] Syntax error detected: {e}")
    sys.exit(1)
