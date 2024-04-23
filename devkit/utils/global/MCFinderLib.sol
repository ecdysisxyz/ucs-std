// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKit} from "devkit/MCDevKit.sol";
// Core
//  functions
import {Bundle} from "devkit/core/Bundle.sol";
import {Function} from "devkit/core/Function.sol";
//  proxy
import {Proxy} from "devkit/core/Proxy.sol";
//  dictionary
import {Dictionary} from "devkit/core/Dictionary.sol";


/**********************************
    🔍 Finder
        🏠 Find Proxy
        📚 Find Dictionary
***********************************/
library MCFinderLib {

    /**-------------------
        🏠 Find Proxy
    ---------------------*/
    function toProxyAddress(MCDevKit storage mc) internal returns(address) {
        return mc.proxy.findCurrent().addr;
    }

    /**------------------------
        📚 Find Dictionary
    --------------------------*/
    function toDictionaryAddress(MCDevKit storage mc) internal returns(address) {
        return mc.dictionary.findCurrent().addr;
    }

}
