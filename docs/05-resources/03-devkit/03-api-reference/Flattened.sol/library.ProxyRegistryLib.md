# ProxyRegistryLib
[Git Source](https://github.com/metacontract/mc/blob/0cf91165f9ec2cbeeba800a4baf4e81e2df5c3bb/src/devkit/Flattened.sol)


## Functions
### register

-----------------------
🗳️ Register Proxy
-------------------------


```solidity
function register(ProxyRegistry storage registry, string memory name, Proxy_2 memory _proxy)
    internal
    returns (Proxy_2 storage proxy);
```

### find

-------------------
🔍 Find Proxy
---------------------


```solidity
function find(ProxyRegistry storage registry, string memory name) internal returns (Proxy_2 storage proxy);
```

### findCurrent


```solidity
function findCurrent(ProxyRegistry storage registry) internal returns (Proxy_2 storage proxy);
```

### genUniqueName

-----------------------------
🏷 Generate Unique Name
-------------------------------


```solidity
function genUniqueName(ProxyRegistry storage registry) internal returns (string memory name);
```

### genUniqueMockName


```solidity
function genUniqueMockName(ProxyRegistry storage registry, string memory baseName)
    internal
    returns (string memory name);
```

