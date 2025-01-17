// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// System
import {System} from "@mc-devkit/system/System.sol";
import {Logger} from "@mc-devkit/system/Logger.sol";
// Types
import {Inspector} from "@mc-devkit/types/Inspector.sol";

using Inspector for bool;

import {Formatter} from "@mc-devkit/types/Formatter.sol";

using Formatter for Process global;
using Formatter for bytes4;
using Formatter for address;
using Formatter for string;
// Core Types

import {MCDevKit} from "@mc-devkit/MCDevKit.sol";
import {Function} from "@mc-devkit/core/Function.sol";
import {FunctionRegistry} from "@mc-devkit/registry/FunctionRegistry.sol";
import {Bundle} from "@mc-devkit/core/Bundle.sol";
import {BundleRegistry} from "@mc-devkit/registry/BundleRegistry.sol";
import {StdRegistry} from "@mc-devkit/registry/StdRegistry.sol";
import {StdFunctions} from "@mc-devkit/registry/StdFunctions.sol";
import {Proxy} from "@mc-devkit/core/Proxy.sol";
import {ProxyRegistry} from "@mc-devkit/registry/ProxyRegistry.sol";
import {Dictionary} from "@mc-devkit/core/Dictionary.sol";
import {DictionaryRegistry} from "@mc-devkit/registry/DictionaryRegistry.sol";
import {Current} from "@mc-devkit/registry/context/Current.sol";

/**
 * =================
 *     ⛓️ Process
 * ===================
 */
/// @custom:storage-location erc7201:mc.devkit.tracer
struct Trace {
    Process[] processStack;
    uint256 nextPid;
    uint256 currentNest;
}

struct Process {
    string libName;
    string funcName;
    string params;
    uint256 nest;
    bool isFinished;
}

library Tracer {
    /**
     * ----------------------------
     *     📈 Execution Tracking
     * ------------------------------
     */
    function start(string memory libName, string memory funcName, string memory params)
        internal
        returns (uint256 pid)
    {
        if (Logger.isDisable()) return 0;
        Trace storage trace = System.Tracer();
        pid = trace.nextPid;
        Process memory process = Process(libName, funcName, params, trace.currentNest, false);
        trace.processStack.push(process);
        trace.currentNest++;
        Logger.logInfo(process.toStart(pid));
        trace.nextPid++;
    }

    function finish(uint256 pid) internal {
        if (Logger.isDisable()) return;
        Trace storage trace = System.Tracer();
        Process storage process = trace.processStack[pid];
        process.isFinished = true;
        Logger.logInfo(process.toFinish(pid));
        trace.currentNest--;
    }

    function traceErrorLocations() internal view returns (string memory locations) {
        Process[] memory processStack = System.Tracer().processStack;
        for (uint256 i = processStack.length; i > 0; --i) {
            Process memory process = processStack[i - 1];
            if (process.isFinished) continue;
            locations = locations.append(process.toLocation());
        }
    }

    /**
     * -----------
     *     🌞 mc
     * -------------
     */
    function startProcess(MCDevKit storage, string memory name, string memory params) internal returns (uint256) {
        return start("mc", name, params);
    }

    function startProcess(MCDevKit storage mc, string memory name) internal returns (uint256) {
        return startProcess(mc, name, "");
    }

    function finishProcess(MCDevKit storage mc, uint256 pid) internal returns (MCDevKit storage) {
        finish(pid);
        return mc;
    }

    // String
    function finishProcess(string memory str, uint256 pid) internal returns (string memory) {
        finish(pid);
        return str;
    }

    /**
     * ------------------
     *     🧩 Function
     * --------------------
     */
    function startProcess(Function storage, string memory name, string memory params) internal returns (uint256) {
        return start("Function", name, params);
    }

    function startProcess(Function storage func, string memory name) internal returns (uint256) {
        return startProcess(func, name, "");
    }

    function finishProcess(Function storage func, uint256 pid) internal returns (Function storage) {
        finish(pid);
        return func;
    }

    /**
     * --------------------------
     *     🧩 Functions Registry
     * ----------------------------
     */
    function startProcess(FunctionRegistry storage, string memory name, string memory params)
        internal
        returns (uint256)
    {
        return start("FunctionRegistry", name, params);
    }

    function startProcess(FunctionRegistry storage functions, string memory name) internal returns (uint256) {
        return functions.startProcess(name, "");
    }

    function finishProcess(FunctionRegistry storage functions, uint256 pid)
        internal
        returns (FunctionRegistry storage)
    {
        finish(pid);
        return functions;
    }

    /**
     * ----------------
     *     🗂️ Bundle
     * ------------------
     */
    function startProcess(Bundle storage, string memory name, string memory params) internal returns (uint256) {
        return start("Bundle", name, params);
    }

    function startProcess(Bundle storage bundle, string memory name) internal returns (uint256) {
        return bundle.startProcess(name, "");
    }

    function finishProcess(Bundle storage bundle, uint256 pid) internal returns (Bundle storage) {
        finish(pid);
        return bundle;
    }

    /**
     * --------------------------
     *     🧩 Bundle Registry
     * ----------------------------
     */
    function startProcess(BundleRegistry storage, string memory name, string memory params)
        internal
        returns (uint256)
    {
        return start("BundleRegistry", name, params);
    }

    function startProcess(BundleRegistry storage bundle, string memory name) internal returns (uint256) {
        return bundle.startProcess(name, "");
    }

    function finishProcess(BundleRegistry storage bundle, uint256 pid) internal returns (BundleRegistry storage) {
        finish(pid);
        return bundle;
    }

    /**
     * -------------------------
     *     🏛 Standard Registry
     * ---------------------------
     */
    function startProcess(StdRegistry storage, string memory name, string memory params) internal returns (uint256) {
        return start("StdRegistryLib", name, params);
    }

    function startProcess(StdRegistry storage std, string memory name) internal returns (uint256) {
        return std.startProcess(name, "");
    }

    function finishProcess(StdRegistry storage std, uint256 pid) internal returns (StdRegistry storage) {
        finish(pid);
        return std;
    }

    /**
     * --------------------------
     *     🏰 Standard Functions
     * ----------------------------
     */
    function startProcess(StdFunctions storage, string memory name, string memory params) internal returns (uint256) {
        return start("StdFunctionsLib", name, params);
    }

    function startProcess(StdFunctions storage std, string memory name) internal returns (uint256) {
        return std.startProcess(name, "");
    }

    function finishProcess(StdFunctions storage std, uint256 pid) internal returns (StdFunctions storage) {
        finish(pid);
        return std;
    }

    /**
     * ---------------
     *     🏠 Proxy
     * -----------------
     */
    function startProcess(Proxy memory, string memory name, string memory params) internal returns (uint256) {
        return start("Proxy", name, params);
    }

    function startProcess(Proxy memory, string memory name) internal returns (uint256) {
        return start("Proxy", name, "");
    }

    function finishProcess(Proxy memory proxy, uint256 pid) internal returns (Proxy memory) {
        finish(pid);
        return proxy;
    }

    function finishProcessInStorage(Proxy storage proxy, uint256 pid) internal returns (Proxy storage) {
        finish(pid);
        return proxy;
    }

    /**
     * ----------------------
     *     🏠 Proxy Registry
     * ------------------------
     */
    function startProcess(ProxyRegistry storage, string memory name, string memory params) internal returns (uint256) {
        return start("ProxyRegistryLib", name, params);
    }

    function startProcess(ProxyRegistry storage proxies, string memory name) internal returns (uint256) {
        return proxies.startProcess(name, "");
    }

    function finishProcess(ProxyRegistry storage proxies, uint256 pid) internal returns (ProxyRegistry storage) {
        finish(pid);
        return proxies;
    }

    /**
     * -------------------
     *     📚 Dictionary
     * ---------------------
     */
    function startProcess(Dictionary memory, string memory name, string memory params) internal returns (uint256) {
        return start("Dictionary", name, params);
    }

    function startProcess(Dictionary memory, string memory name) internal returns (uint256) {
        return start("Dictionary", name, "");
    }

    function finishProcess(Dictionary memory dictionary, uint256 pid) internal returns (Dictionary memory) {
        finish(pid);
        return dictionary;
    }

    function finishProcessInStorage(Dictionary storage dictionary, uint256 pid) internal returns (Dictionary storage) {
        finish(pid);
        return dictionary;
    }

    /**
     * ----------------------------
     *     📚 Dictionary Registry
     * ------------------------------
     */
    function startProcess(DictionaryRegistry storage, string memory name, string memory params)
        internal
        returns (uint256)
    {
        return start("DictionaryRegistryLib", name, params);
    }

    function startProcess(DictionaryRegistry storage dictionaries, string memory name) internal returns (uint256) {
        return dictionaries.startProcess(name, "");
    }

    function finishProcess(DictionaryRegistry storage dictionaries, uint256 pid)
        internal
        returns (DictionaryRegistry storage)
    {
        finish(pid);
        return dictionaries;
    }

    /**
     * ------------------------
     *     📸 Current Context
     * --------------------------
     */
    function startProcess(Current storage, string memory name, string memory params) internal returns (uint256) {
        return start("Current", name, params);
    }

    function startProcess(Current storage current, string memory name) internal returns (uint256) {
        return current.startProcess(name, "");
    }

    function finishProcess(Current storage current, uint256 pid) internal returns (Current storage) {
        finish(pid);
        return current;
    }
}

/**
 * Params
 */
/* solhint-disable 2519 */
function param(string memory str) pure returns (string memory) {
    return str;
}

function param(string memory str, address addr) pure returns (string memory) {
    return str.comma(addr);
}

function param(string memory str, address addr, Function[] memory funcs) pure returns (string memory) {
    return str.comma(addr).comma(param(funcs));
}

function param(string memory str, bytes4 b4, address addr) pure returns (string memory) {
    return str.comma(b4).comma(addr);
}

function param(string memory str, Proxy memory proxy) pure returns (string memory) {
    return str.comma(proxy.addr);
}

function param(string memory str, Dictionary memory dictionary) pure returns (string memory) {
    return str.comma(dictionary.addr);
}

function param(string memory str, Dictionary memory dictionary, bytes memory b) pure returns (string memory) {
    return str.comma(dictionary.addr).comma(string(b));
}

function param(string memory str, Function[] memory funcs) pure returns (string memory) {
    return str.comma(param(funcs));
}

function param(string memory str, bytes memory b) pure returns (string memory) {
    return str.comma(string(b));
}

function param(bytes4 b4) pure returns (string memory) {
    return b4.toString();
}

function param(bytes4 b4, address addr) pure returns (string memory) {
    return b4.toString().comma(addr);
}

function param(address addr) pure returns (string memory) {
    return addr.toString();
}

function param(address addr, address addr2) pure returns (string memory) {
    return addr.toString().comma(addr2);
}

function param(address addr, string memory str) pure returns (string memory) {
    return addr.toString().comma(str);
}

function param(Dictionary memory dict) pure returns (string memory) {
    return param(dict.name);
}

function param(Dictionary memory dict, address addr) pure returns (string memory) {
    return param(dict.addr, addr);
}

function param(Dictionary memory dict, bytes4 b4, address addr) pure returns (string memory) {
    return param(dict.addr).comma(b4).comma(addr);
}

function param(Dictionary memory dict, bytes memory b) pure returns (string memory) {
    return param(dict.addr, string(b));
}

function param(Dictionary memory dict1, Dictionary memory dict2) pure returns (string memory) {
    return param(dict1.addr, dict2.addr);
}

function param(Function memory func) pure returns (string memory) {
    return func.name;
}

function param(Function[] memory functions) pure returns (string memory res) {
    for (uint256 i; i < functions.length; ++i) {
        res = res.comma(functions[i].name);
    }
}

function param(Function[] memory functions, address facade) pure returns (string memory res) {
    return param(functions).comma(facade);
}

function param(Bundle memory bundle) pure returns (string memory) {
    return bundle.name;
}

function param(Bundle memory bundle, address addr) pure returns (string memory) {
    return bundle.name.comma(addr);
}

function param(Bundle memory bundle, bytes memory b) pure returns (string memory) {
    return bundle.name.comma(string(b));
}

function param(Bundle memory bundle, address addr, bytes memory b) pure returns (string memory) {
    return bundle.name.comma(addr).comma(string(b));
}

function param(address addr, bytes memory b) pure returns (string memory) {
    return param(addr).comma(string(b));
}

function param(bytes memory b) pure returns (string memory) {
    return string(b);
}
