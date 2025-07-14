# PoC: Kustomize-First, Helm-Package Workflow

This directory demonstrates how to take an existing Kustomize-managed application and package it as a Helm chart **without modifying the source `base` or `overlays` directories.**

The root folder for this project is `demo-app`.

## How to Run the Demo

### Prerequisites
- `kustomize` (v3.2.0+)
- `helm` (v3+)
- `kubectl` configured to a test cluster (like Docker Desktop)

### 1. Build the Chart for "customer-staging"

Navigate into the project directory and run the build script. This will run Kustomize, apply the staging patches, and wrap the result in a Helm chart.

```bash
cd demo-app
./build_and_package.sh customer-dev

## Strategy Explanation: The "Kustomize-First, Helm-Package" Workflow

This project uses a hybrid strategy that leverages the distinct strengths of both Kustomize and Helm in a sequential pipeline. The goal is to preserve our Kustomize-based configuration management while producing a standardized Helm chart for deployment.

The workflow is as follows:

1.  **Build with Kustomize:** A build process first uses `kustomize build` to generate the final, fully-rendered Kubernetes manifests for a specific environment (e.g., `customer-dev`). This step applies all the necessary patches from the `overlays` to the static `base` manifests.
2.  **Package with Helm:** The resulting multi-document YAML file is then "wrapped" inside a minimal Helm chart. This wrapper chart contains no complex logic; its sole purpose is to act as a container for the pre-rendered manifests.
3.  **Deploy with Helm:** The final output is a standard, versioned Helm chart (`.tgz` file) that can be deployed using standard `helm` commands.

### The Role of Each Tool

This approach creates a clear separation of concerns, where each tool is used for what it does best.

#### Role of Kustomize: The Configuration Engine

Kustomize remains the primary tool for managing the application's configuration and its variations. Its responsibilities are:
*   **Defining the Base State:** Maintaining the static, source-of-truth manifests in the `base` directory.
*   **Managing Variations:** Applying environment-specific patches (e.g., changing replica counts, modifying ConfigMap data) for each customer or environment via the `overlays`.
*   **Developer Experience:** Allowing developers to manage configuration changes declaratively without needing to learn Helm templating.

#### Role of Helm: The Deployment Vehicle

In this workflow, Helm is **not** used for its templating engine. Instead, its role is focused purely on packaging and lifecycle management. Its responsibilities are:
*   **Packaging:** Bundling the final, Kustomized YAML into a single, versioned artifact (`.tgz`).
*   **Distribution:** Enabling the packaged chart to be stored and served from a standard Helm repository (like Artifactory, ChartMuseum, or Harbor).
*   **Lifecycle Management:** Providing a standardized, well-understood interface for deployment (`helm install`, `helm upgrade`, `helm rollback`).
*   **Abstraction:** Hiding the Kustomize complexity from the final deployment stage. The CI/CD pipeline or operations team only needs to interact with a standard Helm chart.

This strategy allows us to adopt Helm for its powerful deployment and packaging capabilities without the significant cost and risk of refactoring our existing, battle-tested Kustomize configurations.