// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {vm, VmSafe, ForgeHelper} from "devkit/utils/ForgeHelper.sol";
import {MessageHead as HEAD} from "devkit/system/message/MessageHead.sol";
import {MessageBody as BODY} from "devkit/system/message/MessageBody.sol";
import {Formatter} from "devkit/types/Formatter.sol";
    using Formatter for string;
import {Logger} from "devkit/system/Logger.sol";
import {Inspector} from "devkit/types/Inspector.sol";
    using Inspector for string;
    using Inspector for bytes4;
    using Inspector for address;
    using Inspector for bool;
    using Inspector for uint256;
// Utils
import {TypeStatus} from "devkit/types/TypeGuard.sol";
import {System} from "devkit/system/System.sol";
// Core Types
import {Function} from "devkit/core/Function.sol";
import {FunctionRegistry} from "devkit/registry/FunctionRegistry.sol";
import {Bundle} from "devkit/core/Bundle.sol";
import {BundleRegistry} from "devkit/registry/BundleRegistry.sol";
import {Proxy, ProxyKind} from "devkit/core/Proxy.sol";
import {ProxyRegistry} from "devkit/registry/ProxyRegistry.sol";
import {Dictionary, DictionaryKind} from "devkit/core/Dictionary.sol";
import {DictionaryRegistry} from "devkit/registry/DictionaryRegistry.sol";
import {StdRegistry} from "devkit/registry/StdRegistry.sol";
import {StdFunctions} from "devkit/registry/StdFunctions.sol";


/**==================
    ✅ Validator
====================*/
library Validator {
    enum Type { MUST, SHOULD, COMPLETION }
    Type constant MUST = Type.MUST;
    Type constant SHOULD = Type.SHOULD;
    Type constant COMPLETION = Type.COMPLETION;

    function validate(Type T, bool condition, string memory messageHead, string memory messageBody) internal returns(bool) {
        if (condition) return true;
        if (T == COMPLETION) Logger.logDebug(Formatter.toMessage(messageHead, messageBody));
        if (T == SHOULD) Logger.logWarn(Formatter.toMessage(messageHead, messageBody));
        if (T == MUST) System.Exit(messageHead, messageBody);
    }

    // Validate without broadcast
    modifier noBroadcast() {
        (VmSafe.CallerMode mode,,) = vm.readCallers();
        if (mode == VmSafe.CallerMode.RecurrentBroadcast) vm.stopBroadcast();
        _;
        if (mode == VmSafe.CallerMode.RecurrentBroadcast) vm.startBroadcast(ForgeHelper.getPrivateKey("DEPLOYER_PRIV_KEY")); // Without CALL TODO

    }


    /**================
        📝 Config
    ==================*/
    function SHOULD_FileExists(string memory path) internal returns(bool condition) {
        condition = vm.exists(path);
        validate(SHOULD, condition, HEAD.CONFIG_FILE_MISSING, BODY.CONFIG_FILE_MISSING);
    }
    function MUST_FileExists(string memory path) internal {
        validate(MUST, vm.exists(path), HEAD.CONFIG_FILE_REQUIRED, BODY.CONFIG_FILE_REQUIRED);
    }

    /**===================
        🧱 Primitives
    =====================*/
    function MUST_NotEmptyName(string memory name) internal {
        validate(MUST, name.isNotEmpty(), HEAD.NAME_REQUIRED, BODY.NAME_REQUIRED);
    }
    function MUST_NotEmptyEnvKey(string memory envKey) internal {
        validate(MUST, envKey.isNotEmpty(), HEAD.ENV_KEY_REQUIRED, BODY.ENV_KEY_REQUIRED);
    }
    function MUST_NotEmptySelector(bytes4 selector) internal {
        validate(MUST, selector.isNotEmpty(), HEAD.SELECTOR_REQUIRED, BODY.SELECTOR_REQUIRED);
    }
    function MUST_AddressIsContract(address addr) internal {
        validate(MUST, addr.isContract(), HEAD.ADDRESS_NOT_CONTRACT, BODY.ADDRESS_NOT_CONTRACT);
    }
    function SHOULD_OwnerIsNotZeroAddress(address owner) internal {
        validate(MUST, owner.isNotZero(), HEAD.OWNER_ZERO_ADDRESS_RECOMMENDED, BODY.OWNER_ZERO_ADDRESS_RECOMMENDED);
    }

    /**==================
        🧩 Function
    ====================*/
    function ValidateBuilder(Function storage func) internal returns(bool) {
        return (
            validate(COMPLETION, func.name.isAssigned(), HEAD.FUNC_NAME_UNASSIGNED, BODY.FUNC_NAME_UNASSIGNED) &&
            validate(COMPLETION, func.selector.isAssigned(), HEAD.FUNC_SELECTOR_UNASSIGNED, BODY.FUNC_SELECTOR_UNASSIGNED) &&
            validate(COMPLETION, func.implementation.isContract(), HEAD.FUNC_CONTRACT_UNASSIGNED, BODY.FUNC_CONTRACT_UNASSIGNED)
        );
    }
    function MUST_Completed(Function memory func) internal {
        validate(MUST, func.isComplete(), HEAD.FUNC_NOT_COMPLETE, BODY.FUNC_NOT_COMPLETE);
    }
    function MUST_NotLocked(Function storage func) internal {
        validate(MUST, func.status.isNotLocked(), HEAD.FUNC_LOCKED, BODY.FUNC_LOCKED);
    }
    function MUST_Building(Function storage func) internal {
        validate(MUST, func.status.isBuilding(), HEAD.FUNC_NOT_BUILDING, BODY.FUNC_NOT_BUILDING);
    }
    function MUST_Built(Function storage func) internal {
        validate(MUST, func.status.isBuilt(), HEAD.FUNC_NOT_BUILT, BODY.FUNC_NOT_BUILT);
    }
    /* 📗 Functions Registry */
    function MUST_Registered(FunctionRegistry storage registry, string memory name) internal {
        validate(MUST, registry.functions[name].isComplete(), HEAD.FUNC_NOT_REGISTERED, BODY.FUNC_NOT_REGISTERED);
    }

    /**===============
        🗂️ Bundle
    =================*/
    function ValidateBuilder(Bundle storage bundle) internal returns(bool) {
        return (
            validate(COMPLETION, bundle.name.isNotEmpty(), HEAD.BUNDLE_NAME_UNASSIGNED, BODY.BUNDLE_NAME_UNASSIGNED) &&
            validate(COMPLETION, bundle.functions.length.isNotZero(), HEAD.NO_FUNCTIONS_IN_BUNDLE, BODY.NO_FUNCTIONS_IN_BUNDLE) &&
            validate(COMPLETION, bundle.facade.isContract(), HEAD.BUNDLE_FACADE_UNASSIGNED, BODY.BUNDLE_FACADE_UNASSIGNED)
        );
    }
    function MUST_NotInitialized(Bundle storage bundle) internal {
        validate(MUST, bundle.status.isUninitialized(), HEAD.BUNDLE_NOT_INITIALIZED, BODY.BUNDLE_NOT_INITIALIZED);
    }
    function SHOULD_Completed(Bundle storage bundle) internal {
        validate(SHOULD, bundle.isComplete(), HEAD.BUNDLE_NOT_COMPLETE, BODY.BUNDLE_NOT_COMPLETE);
    }
    function MUST_HaveUniqueSelector(Bundle storage bundle, Function storage func) internal {
        validate(MUST, bundle.hasNotSameSelector(func), HEAD.BUNDLE_CONTAINS_SAME_SELECTOR, BODY.BUNDLE_CONTAINS_SAME_SELECTOR);
    }
    function MUST_NotLocked(Bundle storage bundle) internal {
        validate(MUST, bundle.status.isNotLocked(), HEAD.BUNDLE_LOCKED, BODY.BUNDLE_LOCKED);
    }
    function MUST_Building(Bundle storage bundle) internal {
        validate(MUST, bundle.status.isBuilding(), HEAD.BUNDLE_NOT_BUILDING, BODY.BUNDLE_NOT_BUILDING);
    }
    function MUST_Built(Bundle storage bundle) internal {
        validate(MUST, bundle.status.isBuilt(), HEAD.BUNDLE_NOT_BUILT, BODY.BUNDLE_NOT_BUILT);
    }
    /* 📙 Bundle Registry */
    function SHOULD_ExistCurrentBundle(BundleRegistry storage registry) internal returns(bool condition) {
        condition = registry.current.name.isNotEmpty();
        validate(SHOULD, condition, HEAD.CURRENT_BUNDLE_NOT_EXIST, BODY.CURRENT_BUNDLE_NOT_EXIST);
    }

    /**==============
        🏠 Proxy
    ================*/
    function ValidateBuilder(Proxy memory proxy) internal returns(bool) {
        return (
            validate(MUST, proxy.addr.isContract(), HEAD.PROXY_ADDR_UNASSIGNED, BODY.PROXY_ADDR_UNASSIGNED) &&
            validate(MUST, proxy.kind.isNotUndefined(), HEAD.PROXY_KIND_UNDEFINED, BODY.PROXY_KIND_UNDEFINED)
        );
    }
    function MUST_Completed(Proxy memory proxy) internal {
        validate(MUST, proxy.isComplete(), HEAD.PROXY_NOT_COMPLETE, BODY.PROXY_NOT_COMPLETE);
    }
    function MUST_NotLocked(Proxy memory proxy) internal {
        validate(MUST, proxy.status.isNotLocked(), HEAD.PROXY_LOCKED, BODY.PROXY_LOCKED);
    }
    function MUST_Building(Proxy memory proxy) internal {
        validate(MUST, proxy.status.isBuilding(), HEAD.PROXY_NOT_BUILDING, BODY.PROXY_NOT_BUILDING);
    }
    function MUST_Built(Proxy memory proxy) internal {
        validate(MUST, proxy.status.isBuilt(), HEAD.PROXY_NOT_BUILT, BODY.PROXY_NOT_BUILT);
    }
    /* 📕 Proxy Registry */
    function MUST_Registered(ProxyRegistry storage registry, string memory name) internal {
        validate(MUST, registry.proxies[name].isComplete(), HEAD.PROXY_NOT_REGISTERED, BODY.PROXY_NOT_REGISTERED);
    }
    function MUST_NotRegistered(ProxyRegistry storage registry, string memory name) internal {
        validate(MUST, registry.proxies[name].isUninitialized(), HEAD.PROXY_ALREADY_REGISTERED, BODY.PROXY_ALREADY_REGISTERED);
    }

    /**====================
        📚 Dictionary
    ======================*/
    function ValidateBuilder(Dictionary memory dictionary) internal returns(bool) {
        return (
            validate(COMPLETION, dictionary.addr.isContract(), HEAD.DICTIONARY_ADDR_UNASSIGNED, BODY.DICTIONARY_ADDR_UNASSIGNED) &&
            validate(COMPLETION, dictionary.kind.isNotUndefined(), HEAD.DICTIONARY_KIND_UNDEFINED, BODY.DICTIONARY_KIND_UNDEFINED)
        );
    }
    function MUST_Completed(Dictionary memory dictionary) internal {
        validate(MUST, dictionary.isComplete(), HEAD.DICTIONARY_NOT_COMPLETE, BODY.DICTIONARY_NOT_COMPLETE);
    }
    function MUST_Verifiable(Dictionary memory dictionary) internal noBroadcast {
        validate(MUST, dictionary.isVerifiable(), HEAD.DICTIONARY_NOT_VERIFIABLE, BODY.DICTIONARY_NOT_VERIFIABLE);
    }
    function MUST_NotLocked(Dictionary memory dictionary) internal {
        validate(MUST, dictionary.status.isNotLocked(), HEAD.DICTIONARY_LOCKED, BODY.DICTIONARY_LOCKED);
    }
    function MUST_Building(Dictionary memory dictionary) internal {
        validate(MUST, dictionary.status.isBuilding(), HEAD.DICTIONARY_NOT_BUILDING, BODY.DICTIONARY_NOT_BUILDING);
    }
    function MUST_Built(Dictionary memory dictionary) internal {
        validate(MUST, dictionary.status.isBuilt(), HEAD.DICTIONARY_NOT_BUILT, BODY.DICTIONARY_NOT_BUILT);
    }
    /* 📘 Dictionary Registry */
    function MUST_Registered(DictionaryRegistry storage registry, string memory name) internal {
        validate(MUST, registry.dictionaries[name].isComplete(), HEAD.DICTIONARY_NOT_REGISTERED, BODY.DICTIONARY_NOT_REGISTERED);
    }
    function MUST_NotRegistered(DictionaryRegistry storage registry, string memory name) internal {
        validate(MUST, registry.dictionaries[name].isUninitialized(), HEAD.DICTIONARY_ALREADY_REGISTERED, BODY.DICTIONARY_ALREADY_REGISTERED);
    }

    /**==========================
        🏛 Standard Registry
    ============================*/
    function ValidateBuilder(StdRegistry storage registry) internal returns(bool) {
        return (
            Validator.ValidateBuilder(registry.functions) &&
            Validator.ValidateBuilder(registry.all)
        );
    }
    function MUST_Completed(StdRegistry storage registry) internal {
        validate(MUST, registry.status.isComplete(), HEAD.STD_REGISTRY_NOT_COMPLETE, BODY.STD_REGISTRY_NOT_COMPLETE);
    }
    function MUST_NotLocked(StdRegistry storage registry) internal {
        validate(MUST, registry.status.isNotLocked(), HEAD.STD_REGISTRY_LOCKED, BODY.STD_REGISTRY_LOCKED);
    }
    function MUST_Building(StdRegistry storage registry) internal {
        validate(MUST, registry.status.isBuilding(), HEAD.STD_REGISTRY_NOT_BUILDING, BODY.STD_REGISTRY_NOT_BUILDING);
    }
    function MUST_Built(StdRegistry memory registry) internal {
        validate(MUST, registry.status.isBuilt(), HEAD.STD_REGISTRY_NOT_BUILT, BODY.STD_REGISTRY_NOT_BUILT);
    }
    /**==========================
        🏰 Standard Functions
    ============================*/
    function ValidateBuilder(StdFunctions storage std) internal returns(bool) {
        return (
            Validator.ValidateBuilder(std.initSetAdmin) &&
            Validator.ValidateBuilder(std.getDeps) &&
            Validator.ValidateBuilder(std.clone)
        );
    }
    function MUST_Completed(StdFunctions storage std) internal {
        validate(MUST, std.status.isComplete(), HEAD.STD_FUNCTIONS_NOT_COMPLETE, BODY.STD_FUNCTIONS_NOT_COMPLETE);
    }
    function MUST_NotLocked(StdFunctions storage std) internal {
        validate(MUST, std.status.isNotLocked(), HEAD.STD_FUNCTIONS_LOCKED, BODY.STD_FUNCTIONS_LOCKED);
    }
    function MUST_Building(StdFunctions storage std) internal {
        validate(MUST, std.status.isBuilding(), HEAD.STD_FUNCTIONS_NOT_BUILDING, BODY.STD_FUNCTIONS_NOT_BUILDING);
    }
    function MUST_Built(StdFunctions memory std) internal {
        validate(MUST, std.status.isBuilt(), HEAD.STD_FUNCTIONS_NOT_BUILT, BODY.STD_FUNCTIONS_NOT_BUILT);
    }

    /**=======================
        🏷️ Name Generator
    =========================*/
    function MUST_FoundInRange() internal {
        validate(MUST, false, HEAD.NOT_FOUND_IN_RANGE, BODY.NOT_FOUND_IN_RANGE);
    }

}
