# IStd
[Git Source](https://github.com/metacontract/mc/blob/df7a49283d8212c99bebd64a186325e91d34c075/plugin-functions/std/interfaces/IStd.sol)

**Inherits:**
[IProxy](/resources/devkit/api-reference/Flattened.sol/interface.IProxy)


## Functions
### clone


```solidity
function clone(bytes calldata initData) external returns (address proxy);
```

### getFunctions


```solidity
function getFunctions() external view returns (GetFunctions.Function[] memory);
```

### featureToggle


```solidity
function featureToggle(bytes4 selector) external;
```

### initSetAdmin


```solidity
function initSetAdmin(address admin) external;
```

### upgradeDictionary


```solidity
function upgradeDictionary(address newDictionary) external;
```
