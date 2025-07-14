#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

CUSTOMER_ENV=$1
if [ -z "$CUSTOMER_ENV" ]; then
  echo "Usage: ./build_and_package.sh <customer_env>"
  echo "Example: ./build_and_package.sh customer-staging"
  exit 1
fi

CHART_VERSION="1.0.0"
BUILD_DIR="./build/${CUSTOMER_ENV}"
CHARTS_OUT_DIR="./charts"

echo -e "\n--- Building and packaging for environment: ${CUSTOMER_ENV} ---"

# 1. Clean and create a temporary build directory
echo "-> Step 1: Cleaning and creating temporary build directory..."
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}

# 2. BUILD THE FINAL MANIFESTS using Kustomize
echo "-> Step 2: Running 'kustomize build' to apply patches..."
kustomize build ./overlays/${CUSTOMER_ENV} > ${BUILD_DIR}/final-manifests.yaml
echo "   Kustomize output generated at ${BUILD_DIR}/final-manifests.yaml"

# 3. CHARTIFY: Wrap the final manifests in a minimal Helm chart
echo "-> Step 3: Creating a simple Helm chart wrapper..."
WRAPPER_CHART_DIR="${BUILD_DIR}/${CUSTOMER_ENV}-chart"
mkdir -p ${WRAPPER_CHART_DIR}/templates

# Create the Chart.yaml for the wrapper chart
cat <<EOF > ${WRAPPER_CHART_DIR}/Chart.yaml
apiVersion: v2
name: ${CUSTOMER_ENV}-demo-app
description: Packaged chart for the PoC App in the ${CUSTOMER_ENV} environment
version: ${CHART_VERSION}
EOF

# Move the final, static manifests into the chart's templates directory
mv ${BUILD_DIR}/final-manifests.yaml ${WRAPPER_CHART_DIR}/templates/manifests.yaml
echo "   Final manifests have been placed into the wrapper chart."

# 4. PACKAGE THE CHART
echo "-> Step 4: Packaging the final Helm chart..."
mkdir -p ${CHARTS_OUT_DIR}
helm package ${WRAPPER_CHART_DIR} -d ${CHARTS_OUT_DIR} > /dev/null

echo -e "\n---"
echo "✅ Success! Deployable Helm chart created at: ${CHARTS_OUT_DIR}/${CUSTOMER_ENV}-demo-app-${CHART_VERSION}.tgz"
echo "---"