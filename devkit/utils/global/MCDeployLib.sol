// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKit} from "devkit/MCDevKit.sol";
import {Config} from "devkit/config/Config.sol";
// Validation
import {validate} from "devkit/validate/Validate.sol";
// Utils
import {Params} from "devkit/log/debug/Params.sol";
// Core
//  dictionary
import {Dictionary, DictionaryLib} from "devkit/core/Dictionary.sol";
//  functions
import {Bundle} from "devkit/core/Bundle.sol";
import {StdFunctionsArgs} from "devkit/registry/StdRegistry.sol";
    using StdFunctionsArgs for address;
//  proxy
import {Proxy, ProxyLib} from "devkit/core/Proxy.sol";

import {MappingAnalyzer} from "devkit/utils/inspector/MappingAnalyzer.sol";
    using MappingAnalyzer for mapping(string => Dictionary);
    using MappingAnalyzer for mapping(string => Proxy);


/***********************************************
    🚀 Deployment
        🌞 Deploy Meta Contract
        🏠 Deploy Proxy
        📚 Deploy Dictionary
        🔂 Duplicate Dictionary
************************************************/
library MCDeployLib {
    string constant LIB_NAME = "MCDeployLib";


    /**-----------------------------
        🌞 Deploy Meta Contract
    -------------------------------*/
    function deploy(MCDevKit storage mc, string memory name, Bundle storage bundleInfo, address owner, bytes memory initData) internal returns(MCDevKit storage) {
        uint pid = mc.recordExecStart("deploy");
        // uint pid = mc.recordExecStart("deploy", PARAMS.append(name).comma().append(bundleInfo.name).comma().append(facade).comma().append(owner).comma().append(string(initData)));
        Dictionary memory dictionary = mc.dictionary.deploy(name, bundleInfo, owner);
        mc.proxy.deploy(name, dictionary, initData);
        return mc.recordExecFinish(pid);
        // TODO gen and set facade
    }

    function deploy(MCDevKit storage mc) internal returns(MCDevKit storage) {
        return mc.deploy(mc.bundle.findCurrent().name, mc.bundle.findCurrent(), Config().defaultOwner(), Config().defaultInitData());
    }
    // function deploy(MCDevKit storage mc, string memory name, Bundle storage bundleInfo, address facade, address owner) internal returns(MCDevKit storage) {
    //     return mc.deploy(name, bundleInfo, facade, owner, Config().defaultInitData());
    // }
    // function deploy(MCDevKit storage mc, string memory name, Bundle storage bundleInfo) internal returns(MCDevKit storage) {
    //     return mc.deploy(name, bundleInfo, Config().defaultInitData(), );
    // }
    // function deploy(MCDevKit storage mc, Bundle storage bundleInfo) internal returns(MCDevKit storage) {
    //     return mc.deploy(Config().defaultName(), bundleInfo, Config().defaultInitData());
    // }
    // function deploy(MCDevKit storage mc, string memory name, bytes memory initData) internal returns(MCDevKit storage) {
    //     return mc.deploy(name, mc.functions.findBundle(name), initData);
    // }
    // function deploy(MCDevKit storage mc, string memory name) internal returns(MCDevKit storage) {
    //     return mc.deploy(name, mc.functions.findBundle(name), Config().defaultInitData());
    // }
    function deploy(MCDevKit storage mc, bytes memory initData) internal returns(MCDevKit storage) {
        return mc.deploy(mc.bundle.findCurrent().name, mc.bundle.findCurrent(), Config().defaultOwner(), initData);
    }


    /**---------------------
        🏠 Deploy Proxy
    -----------------------*/
    function deployProxy(MCDevKit storage mc, string memory name, Dictionary memory dictionary, bytes memory initData) internal returns(MCDevKit storage) {
        uint pid = mc.recordExecStart("deployProxy", Params.append(dictionary.addr, initData));
        Proxy memory proxy = ProxyLib.deploy(dictionary, initData);
        mc.proxy.register(name, proxy);
        return mc.recordExecFinish(pid);
    }
    function deployProxy(MCDevKit storage mc, string memory name, Dictionary storage dictionary, address owner) internal returns(MCDevKit storage) {
        return mc.deployProxy(name, dictionary, owner.initSetAdminBytes());
    }
    function deployProxy(MCDevKit storage mc, string memory name, Dictionary storage dictionary) internal returns(MCDevKit storage) {
        return mc.deployProxy(name, dictionary, Config().defaultOwner().initSetAdminBytes());
    }
    function deployProxy(MCDevKit storage mc, string memory name) internal returns(MCDevKit storage) {
        return mc.deployProxy(name, mc.findCurrentDictionary(), Config().defaultOwner().initSetAdminBytes());
    }
    function deployProxy(MCDevKit storage mc, string memory name, bytes memory initData) internal returns(MCDevKit storage) {
        return mc.deployProxy(name, mc.findCurrentDictionary(), initData);
    }
    function deployProxy(MCDevKit storage mc, bytes memory initData) internal returns(MCDevKit storage) {
        return mc.deployProxy(mc.proxy.proxies.genUniqueName(), mc.findCurrentDictionary(), initData);
    }
    function deployProxy(MCDevKit storage mc) internal returns(MCDevKit storage) {
        return mc.deployProxy(mc.proxy.proxies.genUniqueName(), mc.findCurrentDictionary(), Config().defaultOwner().initSetAdminBytes());
    }


    /**-------------------------
        📚 Deploy Dictionary
    ---------------------------*/
    function deployDictionary(MCDevKit storage mc, string memory name, Bundle storage bundleInfo, address owner) internal returns(Dictionary memory) {
        uint pid = mc.recordExecStart("deployDictionary", Params.append(name, bundleInfo.name, owner));
        Dictionary memory dictionary = DictionaryLib  .deploy(owner)
                                                        .set(bundleInfo)
                                                        .upgradeFacade(bundleInfo.facade);
        mc.dictionary.register(name, dictionary);
        return dictionary.finishProcess(pid);
    }

    function deployDictionary(MCDevKit storage mc) internal returns(Dictionary memory) {
        return mc.deployDictionary(mc.dictionary.dictionaries.genUniqueName(), mc.bundle.findCurrent(), Config().defaultOwner());
    }
    function deployDictionary(MCDevKit storage mc, string memory name) internal returns(Dictionary memory) {
        return mc.deployDictionary(name, mc.bundle.findCurrent(), Config().defaultOwner());
    }
    function deployDictionary(MCDevKit storage mc, Bundle storage bundleInfo) internal returns(Dictionary memory) {
        return mc.deployDictionary(mc.dictionary.dictionaries.genUniqueName(), bundleInfo, Config().defaultOwner());
    }
    function deployDictionary(MCDevKit storage mc, address owner) internal returns(Dictionary memory) {
        return mc.deployDictionary(mc.dictionary.dictionaries.genUniqueName(), mc.bundle.findCurrent(), owner);
    }
    function deployDictionary(MCDevKit storage mc, string memory name, Bundle storage bundleInfo) internal returns(Dictionary memory) {
        return mc.deployDictionary(name, bundleInfo, Config().defaultOwner());
    }
    function deployDictionary(MCDevKit storage mc, string memory name, address owner) internal returns(Dictionary memory) {
        return mc.deployDictionary(name, mc.bundle.findCurrent(), owner);
    }
    function deployDictionary(MCDevKit storage mc, Bundle storage bundleInfo, address owner) internal returns(Dictionary memory) {
        return mc.deployDictionary(mc.dictionary.dictionaries.genUniqueName(), bundleInfo, owner);
    }


    /**----------------------------
        🔂 Duplicate Dictionary
    ------------------------------*/
    function duplicateDictionary(MCDevKit storage mc, string memory name, Dictionary storage targetDictionary) internal returns(MCDevKit storage) {
        uint pid = mc.recordExecStart("duplicateDictionary", Params.append(name, targetDictionary.addr));
        Dictionary memory newDictionary = targetDictionary.duplicate();
        mc.dictionary.register(name, newDictionary);
        return mc.recordExecFinish(pid);
    }
    function duplicateDictionary(MCDevKit storage mc, string memory name) internal returns(MCDevKit storage) {
        return mc.duplicateDictionary(name, mc.findCurrentDictionary());
    }
    function duplicateDictionary(MCDevKit storage mc, Dictionary storage targetDictionary) internal returns(MCDevKit storage) {
        return mc.duplicateDictionary(mc.dictionary.dictionaries.genUniqueDuplicatedName(), targetDictionary);
    }
    function duplicateDictionary(MCDevKit storage mc) internal returns(MCDevKit storage) {
        return mc.duplicateDictionary(mc.dictionary.dictionaries.genUniqueDuplicatedName(), mc.findCurrentDictionary());
    }

}