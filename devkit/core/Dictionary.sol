// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
/**---------------------
    Support Methods
-----------------------*/
import {Tracer, param} from "devkit/system/Tracer.sol";
import {Inspector} from "devkit/types/Inspector.sol";
import {TypeGuard, TypeStatus} from "devkit/types/TypeGuard.sol";
// Validation
import {Validator} from "devkit/system/Validator.sol";
// Util
import {ForgeHelper} from "devkit/utils/ForgeHelper.sol";

// External Libs
import {IDictionary} from "@ucs.mc/dictionary/IDictionary.sol";
import {Dictionary as UCSDictionary} from "@ucs.mc/dictionary/Dictionary.sol";
// Mock
import {DictionaryMock} from "devkit/mocks/DictionaryMock.sol";

// Core Types
import {Function} from "devkit/core/Function.sol";
import {Bundle} from "devkit/core/Bundle.sol";


//////////////////////////////////////////////////
//  📚 Dictionary   //////////////////////////////
    using DictionaryLib for Dictionary global;
    using Tracer for Dictionary global;
    using Inspector for Dictionary global;
    using TypeGuard for Dictionary global;
//////////////////////////////////////////////////
struct Dictionary {
    string name;
    address addr;
    DictionaryKind kind;
    TypeStatus status;
}
library DictionaryLib {
    using Inspector for bytes4;
    /**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        📛 Assign Name
        🚀 Deploy Dictionary
        📩 Load Dictionary
        🔂 Duplicate Dictionary
        🧩 Set Function or Bundle
        🪟 Upgrade Facade
        🤖 Create Dictionary Mock
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

    /**--------------------
        📛 Assign Name
    ----------------------*/
    function assignName(Dictionary memory dictionary, string memory name) internal returns(Dictionary memory) {
        uint pid = dictionary.startProcess("assignName", param(name));
        dictionary.startBuilding();
        dictionary.name = name;
        dictionary.finishBuilding();
        return dictionary.finishProcess(pid);
    }

    /**-------------------------
        🚀 Deploy Dictionary
    ---------------------------*/
    function deploy(address owner) internal returns(Dictionary memory dictionary) {
        uint pid = dictionary.startProcess("deploy", param(owner));
        Validator.SHOULD_OwnerIsNotZeroAddress(owner);
        dictionary.startBuilding();
        dictionary.addr = address(new UCSDictionary(owner));
        dictionary.kind = DictionaryKind.Verifiable;
        dictionary.finishBuilding();
        return dictionary.finishProcess(pid);
    }

    /**-----------------------
        📩 Load Dictionary
    -------------------------*/
    function load(string memory name, address dictionaryAddr) internal returns(Dictionary memory dictionary) {
        uint pid = dictionary.startProcess("load", param(dictionaryAddr));
        Validator.MUST_NotEmptyName(name);
        Validator.MUST_AddressIsContract(dictionaryAddr);
        // TODO Validate
        dictionary.startBuilding();
        dictionary.name = name;
        dictionary.addr = dictionaryAddr;
        dictionary.kind = DictionaryKind.Verifiable; // TODO
        dictionary.finishBuilding();
        return dictionary.finishProcess(pid);
    }

    /**----------------------------
        🔂 Duplicate Dictionary
    ------------------------------*/
    function duplicate(Dictionary storage dictionary, address owner) internal returns(Dictionary memory duplicatedDictionary) {
        uint pid = dictionary.startProcess("duplicate", param(dictionary));
        Validator.MUST_Completed(dictionary);

        duplicatedDictionary = deploy(owner).assignName(dictionary.name);

        address toAddr = duplicatedDictionary.addr;
        address fromAddr = dictionary.addr;

        bytes4[] memory _selectors = IDictionary(fromAddr).supportsInterfaces();
        for (uint i; i < _selectors.length; ++i) {
            bytes4 _selector = _selectors[i];
            if (_selector.isEmpty()) continue;
            duplicatedDictionary.set(_selector, IDictionary(fromAddr).getImplementation(_selector));
        }

        dictionary.finishProcess(pid);
    }

    /**-----------------------------
        🧩 Set Function or Bundle
    -------------------------------*/
    function set(Dictionary memory dictionary, bytes4 selector, address implementation) internal returns(Dictionary memory) {
        uint pid = dictionary.startProcess("set", param(selector, implementation));
        Validator.MUST_Completed(dictionary);
        Validator.MUST_NotEmptySelector(selector);
        Validator.MUST_AddressIsContract(implementation);
        IDictionary(dictionary.addr).setImplementation({
            functionSelector: selector,
            implementation: implementation
        });
        return dictionary.finishProcess(pid);
    }
    function set(Dictionary memory dictionary, Function memory func) internal returns(Dictionary memory) {
        uint pid = dictionary.startProcess("set", param(func));
        set(dictionary, func.selector, func.implementation);
        return dictionary.finishProcess(pid);
    }
    function set(Dictionary memory dictionary, Bundle storage bundle) internal returns(Dictionary memory) {
        uint pid = dictionary.startProcess("set", param(bundle));
        Validator.MUST_HaveFunction(bundle);
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
        uint pid = dictionary.startProcess("upgradeFacade", param(dictionary, newFacade));
        Validator.MUST_AddressIsContract(newFacade);
        Validator.MUST_Verifiable(dictionary);
        IDictionary(dictionary.addr).upgradeFacade(newFacade);
        return dictionary.finishProcess(pid);
    }

    /**------------------------------
        🤖 Create Dictionary Mock
    --------------------------------*/
    function createMock(address owner, Function[] memory functions) internal returns(Dictionary memory dictionary) {
        uint pid = dictionary.startProcess("createMock", param(functions));
        for (uint i; i < functions.length; ++i) {
            Validator.MUST_Completed(functions[i]);
        }
        dictionary.startBuilding();
        dictionary.addr = address(new DictionaryMock(owner, functions));
        dictionary.kind = DictionaryKind.Mock;
        dictionary.finishBuilding();
        return dictionary.finishProcess(pid);
    }

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
