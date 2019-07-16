#!/bin/bash
set -euo pipefail
set -x

. ./util/lib.sh

if [[ "$#" == "0" ]]; then
	echo "Must provide images to update; consider using 'all'"
	exit 1
fi

images=( $@ )

if [[ "$1" == "all" ]]; then
	images=(
		"coreos/alpha"
		"coreos/beta"
		"coreos/stable"
	)
fi

for image in "${images[@]}"; do
	image::update "$image"
done
