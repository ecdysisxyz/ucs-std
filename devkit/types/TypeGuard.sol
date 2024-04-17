// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Inspector} from "devkit/types/Inspector.sol";
    using Inspector for bool;
import {Validate} from "devkit/system/Validate.sol";
// Core Types
import {Function} from "devkit/core/Function.sol";
import {Bundle} from "devkit/core/Bundle.sol";
import {Dictionary} from "devkit/core/Dictionary.sol";
import {Proxy} from "devkit/core/Proxy.sol";
import {StdRegistry} from "devkit/registry/StdRegistry.sol";
import {StdFunctions} from "devkit/registry/StdFunctions.sol";


using TypeGuard for TypeStatus global;
enum TypeStatus { Uninitialized, Building, Built, Locked }

/**===================
    🔒 Type Guard
    @dev See details in docs/object_lifecycle.md
=====================*/
library TypeGuard {
    // Inspect status
    function isUninitialized(TypeStatus status) internal returns(bool) {
        return status == TypeStatus.Uninitialized;
    }
    function isInitialized(TypeStatus status) internal returns(bool) {
        return status != TypeStatus.Uninitialized;
    }
    function isBuilding(TypeStatus status) internal returns(bool) {
        return status == TypeStatus.Building;
    }
    function isBuilt(TypeStatus status) internal returns(bool) {
        return status == TypeStatus.Built;
    }
    function isLocked(TypeStatus status) internal returns(bool) {
        return status == TypeStatus.Locked;
    }
    function isNotLocked(TypeStatus status) internal returns(bool) {
        return status.isLocked().isNot();
    }
    function isComplete(TypeStatus status) internal returns(bool) {
        return status.isBuilt() || status.isLocked();
    }


    /**==================
        🧩 Function
    ====================*/
    function startBuilding(Function storage func) internal returns(Function storage) {
        uint pid = func.startProcess("startBuilding");
        Validate.MUST_NotLocked(func);
        func.status = TypeStatus.Building;
        return func.finishProcess(pid);
    }
    function finishBuilding(Function storage func) internal returns(Function storage) {
        uint pid = func.startProcess("build");
        Validate.MUST_Building(func);
        if (Validate.COMPLETION_NameAssigned(func) &&
            Validate.COMPLETION_SelectorAssigned(func) &&
            Validate.COMPLETION_ImplementationAssigned(func)
        ) func.status = TypeStatus.Built;
        return func.finishProcess(pid);
    }
    function lock(Function storage func) internal returns(Function storage) {
        uint pid = func.startProcess("lock");
        Validate.MUST_Built(func);
        func.status = TypeStatus.Locked;
        return func.finishProcess(pid);
    }
    ///
    function isComplete(Function memory func) internal returns(bool) {
        return func.status.isComplete();
    }
    function isUninitialized(Function storage func) internal returns(bool) {
        return func.status.isUninitialized();
    }


    /**================
        🗂️ Bundle
    ==================*/
    function startBuilding(Bundle storage bundle) internal returns(Bundle storage) {
        uint pid = bundle.startProcess("startBuilding");
        Validate.MUST_NotLocked(bundle);
        bundle.status = TypeStatus.Building;
        return bundle.finishProcess(pid);
    }
    function finishBuilding(Bundle storage bundle) internal returns(Bundle storage) {
        uint pid = bundle.startProcess("finishBuild");
        // Validate.MUST_NameAssigned(bundle);
        // Validate.MUST_HaveAtLeastOneFunction(bundle);
        // Validate.MUST_FacadeAssigned(bundle);
        // bundle.status = TypeStatus.Built;
        if (Validate.Completion(bundle)) bundle.status = TypeStatus.Built;
        return bundle.finishProcess(pid);
    }
    function lock(Bundle storage bundle) internal returns(Bundle storage) {
        Validate.MUST_Built(bundle.status);
        bundle.status = TypeStatus.Locked;
        return bundle;
    }
    function isComplete(Bundle storage bundle) internal returns(bool) {
        return bundle.status.isComplete();
    }
    function isUninitialized(Bundle storage bundle) internal returns(bool) {
        return bundle.status.isUninitialized();
    }


    /**==========================
        🏛 Standard Registry
    ============================*/
    function building(StdRegistry storage registry) internal returns(StdRegistry storage) {
        registry.status = TypeStatus.Building;
        return registry;
    }
    function build(StdRegistry storage registry) internal returns(StdRegistry storage) {
        Validate.MUST_Completed(registry.functions);
        Validate.MUST_completed(registry.all);
        registry.status = TypeStatus.Built;
        return registry;
    }
    function lock(StdRegistry storage registry) internal returns(StdRegistry storage) {
        Validate.MUST_Built(registry.status);
        registry.status = TypeStatus.Locked;
        return registry;
    }
    function finalize(StdRegistry storage registry) internal returns(StdRegistry storage) {
        uint pid = registry.startProcess("finalize");
        registry.build();
        registry.lock();
        return registry.finishProcess(pid);
    }



    /**==========================
        🏰 Standard Functions
    ============================*/
    function building(StdFunctions storage stdFunctions) internal returns(StdFunctions storage) {
        stdFunctions.status = TypeStatus.Building;
        return stdFunctions;
    }
    function build(StdFunctions storage stdFunctions) internal returns(StdFunctions storage) {
        Validate.MUST_Completed(stdFunctions.initSetAdmin);
        Validate.MUST_Completed(stdFunctions.getDeps);
        Validate.MUST_Completed(stdFunctions.clone);
        stdFunctions.status = TypeStatus.Built;
        return stdFunctions;
    }
    function lock(StdFunctions storage stdFunctions) internal returns(StdFunctions storage) {
        Validate.MUST_Built(stdFunctions.status);
        stdFunctions.status = TypeStatus.Locked;
        return stdFunctions;
    }
    function finalize(StdFunctions storage stdFunctions) internal returns(StdFunctions storage) {
        uint pid = stdFunctions.startProcess("finalize");
        stdFunctions.build();
        stdFunctions.lock();
        return stdFunctions.finishProcess(pid);
    }


    /**====================
        📚 Dictionary
    ======================*/
    function startBuilding(Dictionary memory dictionary) internal returns(Dictionary memory) {
        uint pid = dictionary.startProcess("startBuilding");
        Validate.MUST_NotLocked(dictionary);
        dictionary.status = TypeStatus.Building;
        return dictionary.finishProcess(pid);
    }
    function finishBuilding(Dictionary memory dictionary) internal returns(Dictionary memory) {
        uint pid = dictionary.startProcess("finishBuilding");
        if (Validate.Completion(dictionary)) dictionary.status = TypeStatus.Built;
        return dictionary.finishProcess(pid);
    }
    function lock(Dictionary storage dictionary) internal returns(Dictionary storage) {
        Validate.MUST_Built(dictionary.status);
        dictionary.status = TypeStatus.Locked;
        return dictionary;
    }
    function isComplete(Dictionary memory dictionary) internal returns(bool) {
        return dictionary.status.isComplete();
    }
    function isUninitialized(Dictionary storage dictionary) internal returns(bool) {
        return dictionary.status.isUninitialized();
    }


    /**===============
        🏠 Proxy
    =================*/
    function startBuilding(Proxy memory proxy) internal returns(Proxy memory) {
        uint pid = proxy.startProcess("startBuilding");
        Validate.MUST_NotLocked(proxy);
        proxy.status = TypeStatus.Building;
        return proxy.finishProcess(pid);
    }
    function finishBuilding(Proxy memory proxy) internal returns(Proxy memory) {
        uint pid = proxy.startProcess("finishBuilding");
        // Validate.MUST_contractAssigned(proxy);
        // Validate.MUST_kindAssigned(proxy);
        // proxy.status = TypeStatus.Built;
        if (Validate.Completion(proxy)) proxy.status = TypeStatus.Built;
        return proxy.finishProcess(pid);
    }
    function lock(Proxy storage proxy) internal returns(Proxy storage) {
        Validate.MUST_Built(proxy.status);
        proxy.status = TypeStatus.Locked;
        return proxy;
    }
    function isComplete(Proxy memory proxy) internal returns(bool) {
        return proxy.status.isComplete();
    }
    function isInitialized(Proxy storage proxy) internal returns(bool) {
        return proxy.status.isInitialized();
    }
    function isUninitialized(Proxy storage proxy) internal returns(bool) {
        return proxy.status.isUninitialized();
    }
}
