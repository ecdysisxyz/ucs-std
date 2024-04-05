// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKit} from "devkit/MCDevKit.sol";
// Core
//  functions
import {BundleInfo} from "devkit/core/functions/BundleInfo.sol";
import {FuncInfo} from "devkit/core/functions/FuncInfo.sol";
//  proxy
import {Proxy} from "devkit/core/proxy/Proxy.sol";
//  dictionary
import {Dictionary} from "devkit/core/dictionary/Dictionary.sol";


/**********************************
    🔍 Finder
        🗂️ Find Bundle
        🧩 Find Function
        🏠 Find Proxy
        📚 Find Dictionary
***********************************/
using FinderLib for MCDevKit;
library FinderLib {
    string constant LIB_NAME = "MCFinder";

    /**--------------------
        🗂️ Find Bundle
    ----------------------*/
    // function findCurrentBundle(MCDevKit storage mc) internal returns(BundleInfo storage) {
    //     uint pid = mc.recordExecStart("findCurrentBundle");
    //     return mc.functions.findCurrentBundle();
    // }
    function findBundle(MCDevKit storage mc, string memory name) internal returns(BundleInfo storage) {
        return mc.functions.findBundle(name);
    }
    function findCurrentBundleName(MCDevKit storage mc) internal returns(string memory) {
        uint pid = mc.recordExecStart("findCurrentBundleName", "");
        return mc.functions.findCurrentBundleName();
    }

    /**----------------------
        🧩 Find Function
    ------------------------*/
    function findFunction(MCDevKit storage mc, string memory name) internal returns(FuncInfo storage) {
        uint pid = mc.recordExecStart("findFunction");
        return mc.functions.findFunction(name);
    }
    function findCurrentFunction(MCDevKit storage mc) internal returns(FuncInfo storage) {
        uint pid = mc.recordExecStart("findCurrentFunction", "");
        return mc.functions.findCurrentFunction();
    }

    /**-------------------
        🏠 Find Proxy
    ---------------------*/
    function findProxy(MCDevKit storage mc, string memory name) internal returns(Proxy storage) {
        return mc.proxy.find(name);
    }
    function findCurrentProxy(MCDevKit storage mc) internal returns(Proxy storage) {
        return mc.proxy.findCurrentProxy();
    }
    // function findMockProxy(MCDevKit storage mc, string memory name) internal returns(MockProxy) {
    //     return mc.test.findMockProxy(name);
    // }
    function toProxyAddress(MCDevKit storage mc) internal returns(address) {
        return mc.findCurrentProxy().addr;
    }

    /**------------------------
        📚 Find Dictionary
    --------------------------*/
    function findCurrentDictionary(MCDevKit storage mc) internal returns(Dictionary storage) {
        return mc.dictionary.findCurrentDictionary();
    }
    function findDictionary(MCDevKit storage mc, string memory name) internal returns(Dictionary storage) {
        return mc.dictionary.find(name);
    }
    function findMockDictionary(MCDevKit storage mc, string memory name) internal returns(Dictionary storage) {
        return mc.dictionary.findMockDictionary(name);
    }

    function toDictionaryAddress(MCDevKit storage mc) internal returns(address) {
        return mc.findCurrentDictionary().addr;
    }

}
