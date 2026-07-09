#!/bin/bash
# install awscli v2

# --break-system-packages: Debian/Ubuntu's pip refuses global installs
# under PEP 668 (EXTERNALLY-MANAGED) without it. The flag is upstream pip,
# not a Debian-only patch, so it's a harmless no-op on distros (like
# Fedora) that don't enforce the restriction.
pip install --break-system-packages awscliv2
