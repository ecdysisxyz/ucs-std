// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Inspector} from "devkit/types/Inspector.sol";
import {Validate} from "devkit/system/Validate.sol";
// Core Types
import {Function} from "devkit/core/Function.sol";
import {Bundle} from "devkit/core/Bundle.sol";
import {Dictionary} from "devkit/core/Dictionary.sol";
import {Proxy} from "devkit/core/Proxy.sol";
import {StdRegistry} from "devkit/registry/StdRegistry.sol";
import {StdFunctions} from "devkit/registry/StdFunctions.sol";


using Inspector for TypeStatus global;
enum TypeStatus { Uninitialized, Building, Built, Locked }

/**===================
    🔒 Type Guard
    @dev See details in docs/object_lifecycle.md
=====================*/
library TypeGuard {
    using Inspector for bool;

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
        uint pid = func.startProcess("finishBuilding");
        Validate.MUST_Building(func);
        if (Validate.Completion(func)) func.status = TypeStatus.Built;
        return func.finishProcess(pid);
    }
    function lock(Function storage func) internal returns(Function storage) {
        uint pid = func.startProcess("lock");
        Validate.MUST_Built(func);
        func.status = TypeStatus.Locked;
        return func.finishProcess(pid);
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
        uint pid = bundle.startProcess("finishBuilding");
        Validate.MUST_Building(bundle);
        if (Validate.Completion(bundle)) bundle.status = TypeStatus.Built;
        return bundle.finishProcess(pid);
    }
    function lock(Bundle storage bundle) internal returns(Bundle storage) {
        uint pid = bundle.startProcess("lock");
        Validate.MUST_Built(bundle.status);
        bundle.status = TypeStatus.Locked;
        return bundle.finishProcess(pid);
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
        if (Validate.Completion(proxy)) proxy.status = TypeStatus.Built;
        return proxy.finishProcess(pid);
    }
    function lock(Proxy storage proxy) internal returns(Proxy storage) {
        uint pid = proxy.startProcess("lock");
        Validate.MUST_Built(proxy.status);
        proxy.status = TypeStatus.Locked;
        return proxy.finishProcessInStorage(pid);
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
        uint pid = dictionary.startProcess("lock");
        Validate.MUST_Built(dictionary.status);
        dictionary.status = TypeStatus.Locked;
        return dictionary.finishProcessInStorage(pid);
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

}
