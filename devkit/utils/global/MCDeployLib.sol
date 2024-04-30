// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKit} from "devkit/MCDevKit.sol";
import {ForgeHelper} from "devkit/utils/ForgeHelper.sol";
import {System} from "devkit/system/System.sol";
import {Inspector} from "devkit/types/Inspector.sol";
    using Inspector for string;
// Validation
import {Validator} from "devkit/system/Validator.sol";
// Utils
import {param} from "devkit/system/Tracer.sol";
// Core
//  dictionary
import {Dictionary, DictionaryLib} from "devkit/core/Dictionary.sol";
//  functions
import {Bundle} from "devkit/core/Bundle.sol";
//  proxy
import {Proxy, ProxyLib} from "devkit/core/Proxy.sol";

import {NameGenerator} from "devkit/utils/mapping/NameGenerator.sol";
    using NameGenerator for mapping(string => Dictionary);
    using NameGenerator for mapping(string => Proxy);


/***************************************
    🚀 Deployment
        🌞 Deploy Meta Contract
        🏠 Deploy Proxy
        📚 Deploy Dictionary
        🔂 Duplicate Dictionary
****************************************/
library MCDeployLib {

    /**-----------------------------
        🌞 Deploy Meta Contract
    -------------------------------*/
    function deploy(MCDevKit storage mc, Bundle storage bundle, address owner, bytes memory initData) internal returns(MCDevKit storage) {
        uint pid = mc.startProcess("deploy", param(bundle, owner, initData));
        Dictionary storage dictionary = mc.deployDictionary(bundle, owner);
        mc.deployProxy(dictionary, initData);
        return mc.finishProcess(pid);
    }
    // With Default Value
    function deploy(MCDevKit storage mc) internal returns(MCDevKit storage) {
        uint pid = mc.startProcess("deploy");
        mc.deploy(mc.bundle.findCurrent(), ForgeHelper.msgSender(), "");
        return mc.finishProcess(pid);
    }
    function deploy(MCDevKit storage mc, Bundle storage bundle) internal returns(MCDevKit storage) {
        uint pid = mc.startProcess("deploy", param(bundle));
        mc.deploy(bundle, ForgeHelper.msgSender(), "");
        return mc.finishProcess(pid);
    }
    function deploy(MCDevKit storage mc, Bundle storage bundle, address owner) internal returns(MCDevKit storage) {
        uint pid = mc.startProcess("deploy", param(bundle, owner));
        mc.deploy(bundle, owner, "");
        return mc.finishProcess(pid);
    }
    function deploy(MCDevKit storage mc, Bundle storage bundle, bytes memory initData) internal returns(MCDevKit storage) {
        uint pid = mc.startProcess("deploy", param(bundle, initData));
        mc.deploy(bundle, ForgeHelper.msgSender(), initData);
        return mc.finishProcess(pid);
    }
    function deploy(MCDevKit storage mc, address owner) internal returns(MCDevKit storage) {
        uint pid = mc.startProcess("deploy", param(owner));
        mc.deploy(mc.bundle.findCurrent(), owner, "");
        return mc.finishProcess(pid);
    }
    function deploy(MCDevKit storage mc, address owner, bytes memory initData) internal returns(MCDevKit storage) {
        uint pid = mc.startProcess("deploy", param(owner, initData));
        mc.deploy(mc.bundle.findCurrent(), owner, initData);
        return mc.finishProcess(pid);
    }
    function deploy(MCDevKit storage mc, bytes memory initData) internal returns(MCDevKit storage) {
        uint pid = mc.startProcess("deploy", param(initData));
        mc.deploy(mc.bundle.findCurrent(), ForgeHelper.msgSender(), initData);
        return mc.finishProcess(pid);
    }


    /**---------------------
        🏠 Deploy Proxy
    -----------------------*/
    function deployProxy(MCDevKit storage mc, Dictionary storage dictionary, bytes memory initData) internal returns(Proxy memory proxy) {
        uint pid = mc.startProcess("deployProxy", param(dictionary, initData));
        proxy = mc.proxy.deploy(dictionary, initData);
        mc.finishProcess(pid);
    }
    // With Default Value
    function deployProxy(MCDevKit storage mc) internal returns(Proxy memory proxy) {
        uint pid = mc.startProcess("deployProxy");
        proxy = mc.deployProxy(mc.dictionary.findCurrent(), "");
        mc.finishProcess(pid);
    }
    function deployProxy(MCDevKit storage mc, Dictionary storage dictionary) internal returns(Proxy memory proxy) {
        uint pid = mc.startProcess("deployProxy", param(dictionary));
        proxy = mc.deployProxy(dictionary, "");
        mc.finishProcess(pid);
    }
    function deployProxy(MCDevKit storage mc, bytes memory initData) internal returns(Proxy memory proxy) {
        uint pid = mc.startProcess("deployProxy", param(initData));
        proxy = mc.deployProxy(mc.dictionary.findCurrent(), initData);
        mc.finishProcess(pid);
    }


    /**-------------------------
        📚 Deploy Dictionary
    ---------------------------*/
    function deployDictionary(MCDevKit storage mc, Bundle storage bundle, address owner) internal returns(Dictionary storage dictionary) {
        uint pid = mc.startProcess("deployDictionary", param(bundle, owner));
        dictionary = mc.dictionary.deploy(bundle, owner); // TODO gen and set facade
        mc.finishProcess(pid);
    }
    // With Default Value
    function deployDictionary(MCDevKit storage mc) internal returns(Dictionary storage dictionary) {
        uint pid = mc.startProcess("deployDictionary");
        dictionary = mc.deployDictionary(mc.bundle.findCurrent(), ForgeHelper.msgSender());
        mc.finishProcess(pid);
    }
    function deployDictionary(MCDevKit storage mc, Bundle storage bundle) internal returns(Dictionary storage dictionary) {
        uint pid = mc.startProcess("deployDictionary", param(bundle));
        dictionary = mc.deployDictionary(bundle, ForgeHelper.msgSender());
        mc.finishProcess(pid);
    }
    function deployDictionary(MCDevKit storage mc, address owner) internal returns(Dictionary storage dictionary) {
        uint pid = mc.startProcess("deployDictionary", param(owner));
        dictionary = mc.deployDictionary(mc.bundle.findCurrent(), owner);
        mc.finishProcess(pid);
    }


    /**----------------------------
        🔂 Duplicate Dictionary
    ------------------------------*/
    function duplicateDictionary(MCDevKit storage mc, string memory name, Dictionary storage targetDictionary) internal returns(MCDevKit storage) {
        uint pid = mc.startProcess("duplicateDictionary", param(name, targetDictionary));
        Dictionary memory newDictionary = targetDictionary.duplicate();
        mc.dictionary.register(name, newDictionary);
        return mc.finishProcess(pid);
    }
    function duplicateDictionary(MCDevKit storage mc, string memory name) internal returns(MCDevKit storage) {
        return mc.duplicateDictionary(name, mc.dictionary.findCurrent());
    }
    function duplicateDictionary(MCDevKit storage mc, Dictionary storage targetDictionary) internal returns(MCDevKit storage) {
        return mc.duplicateDictionary(mc.dictionary.dictionaries.genUniqueDuplicatedName(), targetDictionary);
    }
    function duplicateDictionary(MCDevKit storage mc) internal returns(MCDevKit storage) {
        return mc.duplicateDictionary(mc.dictionary.dictionaries.genUniqueDuplicatedName(), mc.dictionary.findCurrent());
    }

}
