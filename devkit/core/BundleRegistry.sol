// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Error & Debug
import {check} from "devkit/error/Validation.sol";
import {ERR, throwError} from "devkit/error/Error.sol";
import {Debug} from "devkit/debug/Debug.sol";
// Config
import {ScanRange, Config} from "devkit/config/Config.sol";
// Utils
import {StringUtils} from "devkit/utils/StringUtils.sol";
    using StringUtils for string;
import {BoolUtils} from "devkit/utils/BoolUtils.sol";
    using BoolUtils for bool;
// Core
import {Function} from "./Function.sol";
import {Bundle} from "./Bundle.sol";
import {StdFunctions} from "./StdFunctions.sol";


/**-------------------------------
    🧩 UCS Functions Registry
---------------------------------*/
using BundleRegistryLib for BundleRegistry global;
struct BundleRegistry {
    StdFunctions std;
    mapping(bytes32 nameHash => Function) customs;
    mapping(bytes32 nameHash => Bundle) bundles;
    string currentFunctionName;
    string currentBundleName;
}

/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    << Primary >>
        🌱 Init Bundle
        ✨ Add Custom Function
        🔏 Load and Assign Custom Function from Env
        🧺 Add Custom Function to Bundle
        🪟 Set Facade
        🔼 Update Current Context Function & Bundle
        🔍 Find Function & Bundle
        🏷 Generate Unique Name
    << Helper >>
        🔍 Find Custom Function
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
library BundleRegistryLib {
    string constant LIB_NAME = "BundleRegistry";


    /**---------------------
        🌱 Init Bundle
    -----------------------*/
    function init(BundleRegistry storage functions, string memory name) internal returns(BundleRegistry storage) {
        uint pid = functions.recordExecStart("init");
        functions.bundles[name.safeCalcHash()].safeAssign(name);
        functions.safeUpdateCurrentBundle(name);
        return functions.recordExecFinish(pid);
    }
    function safeInit(BundleRegistry storage functions, string memory name) internal returns(BundleRegistry storage) {
        uint pid = functions.recordExecStart("safeInit");
        check(name.isNotEmpty(), "Empty Name");
        return functions.assertBundleNotExists(name)
                        .init(name)
                        .recordExecFinish(pid);
    }


    /**---------------------------
        ✨ Add Custom Function
    -----------------------------*/
    function safeAddFunction(BundleRegistry storage functions, string memory name, bytes4 selector, address implementation) internal returns(BundleRegistry storage) {
        uint pid = functions.recordExecStart("safeAddFunction");
        check(name.isNotEmpty(), "Empty Name");
        functions.customs[name.safeCalcHash()]
                .safeAssign(name)
                .safeAssign(selector)
                .safeAssign(implementation);
        functions.safeUpdateCurrentFunction(name);
        return functions.recordExecFinish(pid);
    }


    /**---------------------------------------------
        🔏 Load and Add Custom Function from Env
    -----------------------------------------------*/
    function safeLoadAndAdd(BundleRegistry storage functions, string memory envKey, string memory name, bytes4 selector, address implementation) internal returns(BundleRegistry storage) {
        uint pid = functions.recordExecStart("safeLoadAndAdd");
        functions.customs[name.safeCalcHash()]
                    .loadAndAssignFromEnv(envKey, name, selector);
        functions.safeUpdateCurrentFunction(name);
        return functions.recordExecFinish(pid);
    }


    /**-------------------------------------
        🧺 Add Custom Function to Bundle
    ---------------------------------------*/
    function addToBundle(BundleRegistry storage functions, Function storage functionInfo) internal returns(BundleRegistry storage) {
        uint pid = functions.recordExecStart("addToBundle", "function");
        functions.findCurrentBundle().safeAdd(functionInfo);
        return functions.recordExecFinish(pid);
    }
    function addToBundle(BundleRegistry storage functions, Function[] storage functionInfos) internal returns(BundleRegistry storage) {
        uint pid = functions.recordExecStart("addToBundle", "functions"); // TODO params
        functions.findCurrentBundle().safeAdd(functionInfos);
        return functions.recordExecFinish(pid);
    }


    /**------------------
        🪟 Set Facade
    --------------------*/
    function set(BundleRegistry storage functions, string memory name, address facade) internal returns(BundleRegistry storage) {
        uint pid = functions.recordExecStart("set");
        functions.bundles[name.safeCalcHash()]
                    .assertExists()
                    .safeAssign(facade);
        return functions.recordExecFinish(pid);
    }
    function set(BundleRegistry storage functions, address facade) internal returns(BundleRegistry storage) {
        uint pid = functions.recordExecStart("set");
        return functions.set(functions.findCurrentBundleName(), facade).recordExecFinish(pid);
    }


    /**------------------------------------------------
        🔼 Update Current Context Function & Bundle
    --------------------------------------------------*/
    /**----- 🧩 Function -------*/
    function safeUpdateCurrentFunction(BundleRegistry storage functions, string memory name) internal returns(BundleRegistry storage) {
        uint pid = functions.recordExecStart("safeUpdateCurrentFunction");
        functions.currentFunctionName = name.assertNotEmpty();
        return functions.recordExecFinish(pid);
    }
    /**----- 🧺 Bundle -------*/
    function safeUpdateCurrentBundle(BundleRegistry storage functions, string memory name) internal returns(BundleRegistry storage) {
        uint pid = functions.recordExecStart("safeUpdateCurrentBundle");
        functions.currentBundleName = name.assertNotEmpty();
        return functions.recordExecFinish(pid);
    }


    /**-----------------------------------------------
        ♻️ Reset Current Context Function & Bundle
    -------------------------------------------------*/
    function reset(BundleRegistry storage functions) internal returns(BundleRegistry storage) {
        uint pid = functions.recordExecStart("reset");
        delete functions.currentFunctionName;
        delete functions.currentBundleName;
        return functions.recordExecFinish(pid);
    }


    /**-------------------------------
        🔍 Find Function & Bundle
    ---------------------------------*/
    /**----- 🧩 Function -------*/
    function findFunction(BundleRegistry storage functions, string memory name) internal returns(Function storage) {
        uint pid = functions.recordExecStart("findFunction");
        return functions.customs[name.safeCalcHash()].assertExists().finishProcess(pid);
    }
    function findCurrentFunction(BundleRegistry storage functions) internal returns(Function storage) {
        uint pid = functions.recordExecStart("findCurrentFunction");
        return functions.findFunction(functions.findCurrentFunctionName()).finishProcess(pid);
    }
        function findCurrentFunctionName(BundleRegistry storage functions) internal returns(string memory) {
            uint pid = functions.recordExecStart("findCurrentFunctionName");
            return functions.currentFunctionName.assertNotEmpty().recordExecFinish(pid);
        }

    /**----- 🧺 Bundle -------*/
    function findBundle(BundleRegistry storage functions, string memory name) internal returns(Bundle storage) {
        uint pid = functions.recordExecStart("findBundle");
        return functions.bundles[name.safeCalcHash()].recordExecFinish(pid);
    }
    function findCurrentBundle(BundleRegistry storage functions) internal returns(Bundle storage) {
        uint pid = functions.recordExecStart("findCurrentBundle");
        return functions.findBundle(functions.findCurrentBundleName()).recordExecFinish(pid);
    }
        function findCurrentBundleName(BundleRegistry storage functions) internal returns(string memory) {
            uint pid = functions.recordExecStart("findCurrentBundleName");
            return functions.currentBundleName.assertNotEmpty().recordExecFinish(pid);
        }


    /**-----------------------------
        🏷 Generate Unique Name
    -------------------------------*/
    function genUniqueBundleName(BundleRegistry storage functions) internal returns(string memory name) {
        uint pid = functions.recordExecStart("genUniqueBundleName");
        ScanRange storage range = Config().SCAN_RANGE;
        for (uint i = range.START; i <= range.END; ++i) {
            name = Config().DEFAULT_BUNDLE_NAME.toSequential(i);
            if (functions.existsBundle(name).isFalse()) return name.recordExecFinish(pid);
        }
        throwError(ERR.FIND_NAME_OVER_RANGE);
    }



    /**-------------------------------
        🧐 Inspectors & Assertions
    ---------------------------------*/
    function existsBundle(BundleRegistry storage functions, string memory name) internal returns(bool) {
        return functions.bundles[name.safeCalcHash()].hasName();
    }
    function notExistsBundle(BundleRegistry storage functions, string memory name) internal returns(bool) {
        return functions.existsBundle(name).isNot();
    }
    function assertBundleNotExists(BundleRegistry storage functions, string memory name) internal returns(BundleRegistry storage) {
        check(functions.notExistsBundle(name), "Bundle Already Exists");
        return functions;
    }

    function existsCurrentBundle(BundleRegistry storage functions) internal returns(bool) {
        return functions.currentBundleName.isNotEmpty();
    }
    function notExistsCurrentBundle(BundleRegistry storage functions) internal returns(bool) {
        return functions.existsCurrentBundle().isNot();
    }


    /**----------------
        🐞 Debug
    ------------------*/
    /**
        Record Start
     */
    function recordExecStart(BundleRegistry storage, string memory funcName, string memory params) internal returns(uint) {
        return Debug.recordExecStart(LIB_NAME, funcName, params);
    }
    function recordExecStart(BundleRegistry storage functions, string memory funcName) internal returns(uint) {
        return functions.recordExecStart(funcName, "");
    }

    /**
        Record Finish
     */
    function recordExecFinish(BundleRegistry storage functions, uint pid) internal returns(BundleRegistry storage) {
        Debug.recordExecFinish(pid);
        return functions;
    }

}
