#!/usr/bin/env python3
"""Reemplaza ${VARIABLES} en un template usando variables de entorno."""

import os
import sys


def main() -> int:
    if len(sys.argv) != 3:
        print(f"Uso: {sys.argv[0]} <template> <salida>", file=sys.stderr)
        return 2

    template, output = sys.argv[1:]
    with open(template, encoding="utf-8") as handle:
        content = handle.read()
    with open(output, "w", encoding="utf-8") as handle:
        handle.write(os.path.expandvars(content))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
