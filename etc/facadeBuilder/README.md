# how to generate facade
- `cp facade.yaml ../../`
- Write the configuration based on the following YAML Specification.
- `node ./facadeBuilder.js`

# How to build everytime you change facadeBuilder.ts
- `npm run exec`

# Solidity Bundle Configuration YAML Specification

## Overview

This YAML specification is specifically designed for Solidity smart contract bundle configurations, providing a flexible way to define contract facades and exclusion rules.

## Structure

### Bundle Properties

| Property | Type | Description | Required | Default Behavior |
|----------|------|-------------|----------|-----------------|
| `bundleName` | String | Human-readable name of the Solidity bundle | ✓ | - |
| `bundleDirName` | String | Directory name for the bundle | × | Falls back to `bundleName` |
| `facades` | List | Definitions of contract facades | ✓ | - |

### Facade Properties for Solidity

| Property | Type | Description | Required |
|----------|------|-------------|----------|
| `name` | String | Name of the contract facade | ✓ |
| `excludeFileNames` | List of Strings | Solidity contract files to exclude | × |
| `excludeFunctionNames` | List of Strings | Function names to exclude from the facade | × |

## Project Structure

### Required Directory Layout
```
project/
├── src/
│   └── {bundleDirName}/
│       ├── functions/      # Contains contract function implementations
│       ├── interfaces/     # Contains error and event interface definitions
│       └── storage/
│           └── Schema.sol  # Base schema contract
└── generated/             # Output directory for generated facades
```

### Interface File Naming Conventions
- Error interface files must match pattern: `(I)?.*Errors.sol`
- Event interface files must match pattern: `(I)?.*Events.sol`

## Generated Facade Contract Specifications

### Contract Structure
1. SPDX License Identifier: MIT
2. Solidity version: ^0.8.24
3. Imports:
   - Schema.sol from bundleDirName
   - All error and event interfaces
4. Contract inheritance: Extends Schema and all imported interfaces

### Function Generation Rules
- Skip functions that are:
  - Unnamed (constructor, fallback, receive)
  - Start with "test"
  - Named "setUp"
  - Marked as private or internal
  - Listed in excludeFunctionNames
- Default visibility is "public" if not specified

## Versioning System

### Version Format
- Format: `{facadeName}V{major}_{minor}_{patch}.sol`
- Example: `TextDAOFacadeV1_0_0.sol`

### Version Increment Rules
1. Major Version (X.0.0):
   - Incremented when function signatures change (name or parameters)
   - Resets minor and patch versions to 0
2. Minor Version (0.X.0):
   - Incremented when errors or events change
   - Resets patch version to 0
3. Patch Version (0.0.X):
   - Reserved for future use

## Examples

### Solidity Contract Bundle Configuration
```yaml
- bundleName: "TextDAO"
  facades:
    - name: "TextDAOFacade"
      excludeFileNames:
        - "OnlyAdminCheats.sol"
      excludeFunctionNames:
        - "adminOnly"
        - "internalUpgrade"
```

### Multiple Facade Configuration
```yaml
- bundleName: "GovernanceContract"
  facades:
    - name: "PublicFacade"
      excludeFileNames:
        - "AdminControls.sol"
      excludeFunctionNames:
        - "emergencyStop"
    
    - name: "AdminFacade"
      excludeFileNames:
        - "PublicInteractions.sol"
```

## Solidity-Specific Considerations

### File Exclusions
- Typically used to separate administrative or sensitive contract files
- Can exclude utility contracts, test contracts, or partial implementations
- Helps in managing contract visibility and access

### Function Exclusions
- Prevents exposure of internal or administrative functions
- Useful for creating restricted interfaces
- Supports creating different levels of contract access

## Validation Rules

1. `bundleName` must be a non-empty string
2. If `bundleDirName` is not provided, use `bundleName` as the directory name
3. Each bundle must have at least one facade
4. Exclusions apply to Solidity (`.sol`) files and function names
5. Excluded elements are removed from the generated facade interface

## Best Practices

- Use clear naming conventions for contracts and functions
- Be intentional about what is included or excluded
- Consider security implications of facade design
- Align exclusions with access control and contract architecture