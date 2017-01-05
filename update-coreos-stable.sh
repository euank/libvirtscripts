#!/bin/bash
set -euo pipefail
set -x

. ./util/lib.sh

image::update_coreos_image "stable"

echo "Updated to: $(image::latest_coreos_stable)"
