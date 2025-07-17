#!/bin/bash

# Example usage: ./build_and_package.sh demo-app/overlays/dev

kustomize build $1 > ./build/manifests.yaml

mkdir -p ./build/chart/templates
mv ./build/manifests.yaml ./build/chart/templates/

cat <<EOF > ./build/chart/Chart.yaml
apiVersion: v2
name: my-app
version: 1.0.0
EOF

helm package ./build/chart -d ./charts