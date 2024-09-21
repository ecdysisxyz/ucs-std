# MCDeployLib
[Git Source](https://github.com/metacontract/mc/blob/c3fc2b414d37afc92bb1cf2e606b4b2bede47403/resources/devkit/api-reference/Flattened.sol)

🚀 Deployment
🌞 Deploy Meta Contract
- Deploy
- DeployImmutable
- DeployRestrictedUpgradeable
- DeployContractUpgradeable
🏠 Deploy Proxy
📚 Deploy Dictionary
🔂 Duplicate Dictionary
💽 Load Dictionary


## Functions
### deploy

-----------------------------
🌞 Deploy Meta Contract
-------------------------------


```solidity
function deploy(MCDevKit storage mc, Bundle storage bundle, address owner, bytes memory initData)
    internal
    returns (MCDevKit storage);
```

### deploy


```solidity
function deploy(MCDevKit storage mc) internal returns (MCDevKit storage);
```

### deploy


```solidity
function deploy(MCDevKit storage mc, Bundle storage bundle) internal returns (MCDevKit storage);
```

### deploy


```solidity
function deploy(MCDevKit storage mc, Bundle storage bundle, address owner) internal returns (MCDevKit storage);
```

### deploy


```solidity
function deploy(MCDevKit storage mc, Bundle storage bundle, bytes memory initData)
    internal
    returns (MCDevKit storage);
```

### deploy


```solidity
function deploy(MCDevKit storage mc, address owner) internal returns (MCDevKit storage);
```

### deploy


```solidity
function deploy(MCDevKit storage mc, address owner, bytes memory initData) internal returns (MCDevKit storage);
```

### deploy


```solidity
function deploy(MCDevKit storage mc, bytes memory initData) internal returns (MCDevKit storage);
```

### deployProxy

---------------------
🏠 Deploy Proxy
-----------------------


```solidity
function deployProxy(MCDevKit storage mc, Dictionary_1 storage dictionary, bytes memory initData)
    internal
    returns (Proxy_2 memory proxy);
```

### deployProxy

*Accepts any initData as input*


```solidity
function deployProxy(MCDevKit storage mc) internal returns (Proxy_2 memory proxy);
```

### deployProxy


```solidity
function deployProxy(MCDevKit storage mc, Dictionary_1 storage dictionary) internal returns (Proxy_2 memory proxy);
```

### deployProxy


```solidity
function deployProxy(MCDevKit storage mc, bytes memory initData) internal returns (Proxy_2 memory proxy);
```

### deployDictionary

-------------------------
📚 Deploy Dictionary
---------------------------


```solidity
function deployDictionary(MCDevKit storage mc, Bundle storage bundle, address owner)
    internal
    returns (Dictionary_1 storage dictionary);
```

### deployDictionary


```solidity
function deployDictionary(MCDevKit storage mc) internal returns (Dictionary_1 storage dictionary);
```

### deployDictionary


```solidity
function deployDictionary(MCDevKit storage mc, Bundle storage bundle)
    internal
    returns (Dictionary_1 storage dictionary);
```

### deployDictionary


```solidity
function deployDictionary(MCDevKit storage mc, address owner) internal returns (Dictionary_1 storage dictionary);
```

### duplicateDictionary

----------------------------
🔂 Duplicate Dictionary
------------------------------


```solidity
function duplicateDictionary(MCDevKit storage mc, Dictionary_1 storage dictionary, address owner)
    internal
    returns (Dictionary_1 storage duplicatedDictionary);
```

### duplicateDictionary


```solidity
function duplicateDictionary(MCDevKit storage mc) internal returns (Dictionary_1 storage duplicatedDictionary);
```

### duplicateDictionary


```solidity
function duplicateDictionary(MCDevKit storage mc, Dictionary_1 storage dictionary)
    internal
    returns (Dictionary_1 storage duplicatedDictionary);
```

### duplicateDictionary


```solidity
function duplicateDictionary(MCDevKit storage mc, address owner)
    internal
    returns (Dictionary_1 storage duplicatedDictionary);
```

### loadDictionary

------------------------
💽 Load Dictionary
--------------------------


```solidity
function loadDictionary(MCDevKit storage mc, string memory name, address dictionaryAddr)
    internal
    returns (Dictionary_1 storage dictionary);
```

