---
keywords: [meta-contract, installation, setup, development-environment]
tags: [meta-contract, installation, setup, development-environment]
last_update:
  date: 2024-10-26
  author: Meta Contract Development Team
---

# Installation

This guide will walk you through the process of installing Meta Contract, a Foundry-based smart contract framework.

## Prerequisites

Before installing Meta Contract, ensure you have the following:

1. [Foundry](https://book.getfoundry.sh/getting-started/installation) installed on your system (version 0.2.0 or later)
2. Git installed on your system
3. A code editor of your choice (e.g., Cursor, Visual Studio Code)

## Installation Steps

1. Initialize your project with the meta contract template:

    ```bash
    forge init <project-name> -t metacontract/template
    ```

2. Navigate to your project directory:

    ```bash
    cd <project-name>
    ```

3. Install the dependencies using Foundry:

    ```bash
    forge install
    ```

4. Build the project:

    ```bash
    forge build
    ```

5. Run the tests to ensure everything is working correctly:

    ```bash
    forge test
    ```

## Troubleshooting

If you encounter any issues during the installation process, try the following:

1. **Forge command not found**: Ensure that Foundry is correctly installed and added to your system PATH.

2. **Dependency installation fails**: Check your internet connection and try running `forge install` again. If the issue persists, manually clone the required repositories into the `lib` directory.

3. **Build errors**: Make sure you have the latest version of Foundry installed. You can update Foundry using `foundryup`.

If you're still experiencing issues, please reach out to [our community](https://github.com/orgs/metacontract/discussions) for support.

## Next Steps

Now that you have Meta Contract installed, proceed to the [Basic Setup](02-basic-setup.md) guide to configure your development environment and start working on your first Meta Contract project.
