// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
/**---------------------
    Support Methods
-----------------------*/
import {ProcessLib} from "devkit/core/method/debug/ProcessLib.sol";
    using ProcessLib for Dictionary global;
import {Params} from "devkit/debug/Params.sol";
import {Inspector} from "devkit/core/method/inspector/Inspector.sol";
    using Inspector for Dictionary global;
import {ForgeHelper} from "devkit/utils/ForgeHelper.sol";
// Type Util
import {Bytes4Utils} from "devkit/utils/Bytes4Utils.sol";
    using Bytes4Utils for bytes4;
// Validation
import {Require} from "devkit/error/Require.sol";
import {TypeGuard, TypeStatus} from "devkit/core/types/TypeGuard.sol";
    using TypeGuard for Dictionary global;

// Mock
import {DictionaryMock} from "devkit/mocks/DictionaryMock.sol";
// External Libs
import {IDictionary} from "@ucs.mc/dictionary/IDictionary.sol";
import {DictionaryEtherscan} from "@ucs.mc/dictionary/DictionaryEtherscan.sol";

// Core Types
import {Function} from "devkit/core/types/Function.sol";
import {Bundle} from "devkit/core/types/Bundle.sol";


/**====================
    📚 Dictionary
======================*/
using DictionaryLib for Dictionary global;
struct Dictionary {
    address addr;
    DictionaryKind kind;
    TypeStatus status;
}
library DictionaryLib {
    /**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        🚀 Deploy Dictionary
        🔂 Duplicate Dictionary
        🧩 Set Function or Bundle
        🪟 Upgrade Facade
        🤖 Create Mock Dictionary
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /**-------------------------
        🚀 Deploy Dictionary
    ---------------------------*/
    function deploy(address owner) internal returns(Dictionary memory) {
        uint pid = ProcessLib.startDictionaryLibProcess("deploy");
        Require.notZero(owner);
        /// @dev Until Etherscan supports UCS, we are deploying contracts with additional features for Etherscan compatibility by default.
        return Dictionary({
            addr: address(new DictionaryEtherscan(owner)),
            kind: DictionaryKind.Verifiable,
            status: TypeStatus.Building
        }).finishProcess(pid);
    }

    /**----------------------------
        🔂 Duplicate Dictionary
    ------------------------------*/
    function duplicate(Dictionary memory toDictionary, Dictionary memory fromDictionary) internal returns(Dictionary memory) {
        uint pid = ProcessLib.startDictionaryLibProcess("duplicate");
        Require.notEmpty(toDictionary);
        Require.notEmpty(fromDictionary);

        address toAddr = toDictionary.addr;
        address fromAddr = fromDictionary.addr;

        bytes4[] memory _selectors = IDictionary(fromAddr).supportsInterfaces();
        for (uint i; i < _selectors.length; ++i) {
            bytes4 _selector = _selectors[i];
            if (_selector.isEmpty()) continue;
            toDictionary.set(_selector, IDictionary(fromAddr).getImplementation(_selector));
        }

        return toDictionary.finishProcess(pid);
    }
    function duplicate(Dictionary memory fromDictionary) internal returns(Dictionary memory) {
        return duplicate(deploy(ForgeHelper.msgSender()), fromDictionary);
    }


    /**-----------------------------
        🧩 Set Function or Bundle
    -------------------------------*/
    function set(Dictionary memory dictionary, bytes4 selector, address implementation) internal returns(Dictionary memory) {
        uint pid = ProcessLib.startDictionaryLibProcess("set", Params.append(selector, implementation));
        Require.isContract(dictionary.addr);
        Require.notEmpty(selector);
        Require.isContract(implementation);
        IDictionary(dictionary.addr).setImplementation({
            functionSelector: selector,
            implementation: implementation
        });
        return dictionary.finishProcess(pid);
    }
    function set(Dictionary memory dictionary, Function memory func) internal returns(Dictionary memory) {
        uint pid = ProcessLib.startDictionaryLibProcess("set", Params.append(func.name));
        return set(dictionary, func.selector, func.implementation).finishProcess(pid);
    }
    function set(Dictionary memory dictionary, Bundle storage bundle) internal returns(Dictionary memory) {
        uint pid = ProcessLib.startDictionaryLibProcess("set", Params.append(bundle.name));

        Function[] memory functions = bundle.functions;

        for (uint i; i < functions.length; ++i) {
            set(dictionary, functions[i]);
        }

        // TODO Generate Facade
        // if (dictionary.isVerifiable()) {
        //     dictionary.upgradeFacade(bundle.facade);
        // }

        return dictionary.finishProcess(pid);
    }


    /**----------------------
        🪟 Upgrade Facade
    ------------------------*/
    function upgradeFacade(Dictionary memory dictionary, address newFacade) internal returns(Dictionary memory) {
        uint pid = ProcessLib.startDictionaryLibProcess("upgradeFacade");
        Require.isContract(newFacade);
        // Require.verifiable(dictionary); TODO without CALL
        DictionaryEtherscan(dictionary.addr).upgradeFacade(newFacade);
        return dictionary.finishProcess(pid);
    }


    /**------------------------------
        🤖 Create Mock Dictionary
    --------------------------------*/
    function createMockDictionary(address owner, Function[] memory functions) internal returns(Dictionary memory) {
        uint pid = ProcessLib.startDictionaryLibProcess("createMockDictionary");
        return Dictionary({
            addr: address(new DictionaryMock(owner, functions)),
            kind: DictionaryKind.Mock,
            status: TypeStatus.Building
        }).finishProcess(pid);
    }



    // function assignLabel(Dictionary storage dictionary, string memory name) internal returns(Dictionary storage) {
    //     ForgeHelper.assignLabel(dictionary.addr, name);
    //     return dictionary;
    // }
}


/**--------------------
    Dictionary Kind
----------------------*/
enum DictionaryKind {
    undefined,
    Verifiable,
    Mock
}
using Inspector for DictionaryKind global;
