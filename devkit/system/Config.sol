// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ForgeHelper, vm} from "devkit/utils/ForgeHelper.sol";
import {Logger} from "devkit/system/Logger.sol";
import {Validator} from "devkit/system/Validator.sol";

import {stdToml} from "forge-std/StdToml.sol";
    using stdToml for string;
import {Parser} from "devkit/types/Parser.sol";
    using Parser for string;

/**----------------------
    📝 Config
------------------------*/
using ConfigLib for ConfigState global;

/**===============\
|   📝 Config     |
\================*/
/// @custom:storage-location erc7201:mc.devkit.config
struct ConfigState {
    SetupConfig SETUP;
    SystemConfig SYSTEM;
    NamingConfig DEFAULT_NAME;
}
    struct SetupConfig {
        bool STD_FUNCS;
    }
    struct SystemConfig {
        Logger.Level LOG_LEVEL;
        uint SCAN_RANGE;
    }
    struct NamingConfig {
        string DICTIONARY;
        string DICTIONARY_DUPLICATED;
        string DICTIONARY_MOCK;
        string PROXY;
        string PROXY_MOCK;
        string BUNDLE;
        string FUNCTION;
    }

library ConfigLib {
    function load(ConfigState storage config) internal {
        loadFromLibMC(config);
        loadFromProjectRoot(config);
    }

    function loadFromLibMC(ConfigState storage config) internal {
        string memory path = string.concat(vm.projectRoot(), "/lib/mc/mc.toml");
        if (Validator.SHOULD_FileExists(path)) config.loadFrom(path);
    }
    function loadFromProjectRoot(ConfigState storage config) internal {
        string memory path = string.concat(vm.projectRoot(), "/mc.toml");
        if (Validator.SHOULD_FileExists(path)) config.loadFrom(path);
    }

    function loadFrom(ConfigState storage config, string memory path) internal {
        string memory toml = vm.readFile(path);
        // Setup
        config.SETUP.STD_FUNCS = toml.readBool(".setup.STD_FUNCS");
        // System
        config.SYSTEM.LOG_LEVEL = toml.readString(".system.LOG_LEVEL").toLogLevel();
        config.SYSTEM.SCAN_RANGE = toml.readUint(".system.SCAN_RANGE");
        // Naming
        config.DEFAULT_NAME.DICTIONARY = toml.readString(".naming.DEFAULT_DICTIONARY");
        config.DEFAULT_NAME.DICTIONARY_DUPLICATED = toml.readString(".naming.DEFAULT_DICTIONARY_DUPLICATED");
        config.DEFAULT_NAME.DICTIONARY_MOCK = toml.readString(".naming.DEFAULT_DICTIONARY_MOCK");
        config.DEFAULT_NAME.PROXY = toml.readString(".naming.DEFAULT_PROXY");
        config.DEFAULT_NAME.PROXY_MOCK = toml.readString(".naming.DEFAULT_PROXY_MOCK");
        config.DEFAULT_NAME.BUNDLE = toml.readString(".naming.DEFAULT_BUNDLE");
        config.DEFAULT_NAME.FUNCTION = toml.readString(".naming.DEFAULT_FUNCTION");
    }

    function defaultOwner(ConfigState storage) internal returns(address) {
        return ForgeHelper.msgSender();
    }

    function defaultName(ConfigState storage) internal pure returns(string memory) {
        return "ProjectName"; // TODO
    }

    // function defaultProxyName(MCDevKit storage mc) internal returns(string memory) {
    //     return mc.proxy.genUniqueName();
    // }
    // function defaultMockProxyName(MCDevKit storage mc) internal returns(string memory) {
    //     return mc.proxy.genUniqueMockName();
    // }

    // function defaultDictionaryName(MCDevKit storage mc) internal returns(string memory) {
    //     return mc.dictionary.genUniqueName();
    // }
    // function defaultDuplicatedDictionaryName(MCDevKit storage mc) internal returns(string memory) {
    //     return mc.dictionary.genUniqueDuplicatedName();
    // }
    // function defaultMockDictionaryName(MCDevKit storage mc) internal returns(string memory) {
    //     return mc.dictionary.genUniqueMockName();
    // }

    // function defaultFunctionInfos(MCDevKit storage mc) internal returns(Function[] storage) {
    //     return mc.functions.std.allFunctions.functions;
    // }
    // function defaultBundleName(MCDevKit storage mc) internal returns(string memory) {
    //     return mc.functions.genUniqueBundleName();
    // }

    function defaultInitData(ConfigState storage) internal pure returns(bytes memory) {
        return "";
    }
}
