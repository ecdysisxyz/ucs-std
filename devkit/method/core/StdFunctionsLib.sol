// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Utils
import {console2} from "devkit/utils/ForgeHelper.sol";
import {AddressUtils} from "devkit/utils/AddressUtils.sol";
    using AddressUtils for address;
import {StringUtils} from "devkit/utils/StringUtils.sol";
    using StringUtils for string;
// Debug
import {Debug} from "devkit/debug/Debug.sol";
import {Logger} from "devkit/debug/Logger.sol";
// Core
import {Function} from "devkit/core/Function.sol";
import {Bundle} from "devkit/core/Bundle.sol";
// MC Std
import {Clone} from "mc-std/functions/Clone.sol";
import {GetDeps} from "mc-std/functions/GetDeps.sol";
import {FeatureToggle} from "mc-std/functions/protected/FeatureToggle.sol";
import {InitSetAdmin} from "mc-std/functions/protected/InitSetAdmin.sol";
import {UpgradeDictionary} from "mc-std/functions/protected/UpgradeDictionary.sol";
import {StdFacade} from "mc-std/interfaces/StdFacade.sol";

import {StdFunctions} from "devkit/core/StdFunctions.sol";
// Loader
import {loadAddressFrom} from "devkit/utils/ForgeHelper.sol";


/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    🏛 Standard Functions
        🔏 Assign and Load Standard Functions
        🐣 Deploy Standard Functions If Not Exists
        🧺 Configure Standard Bundles
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
library StdFunctionsLib {

    /**------------------------------------------
        🔏 Assign and Load Standard Functions
    --------------------------------------------*/
    function assignAndLoad(StdFunctions storage std) internal returns(StdFunctions storage) {
        uint pid = std.startProcess("assignAndLoad");
        return std  .assignAndLoad_InitSetAdmin()
                    .assignAndLoad_GetDeps()
                    .assignAndLoad_Clone()
                    .finishProcess(pid);
    }

        /**===== Each Std Function =====*/
        function assignAndLoad_InitSetAdmin(StdFunctions storage std) internal returns(StdFunctions storage) {
            uint pid = std.startProcess("assignAndLoad_InitSetAdmin");
            string memory name = "InitSetAdmin";
            bytes4 selector = InitSetAdmin.initSetAdmin.selector;
            address implementation = loadAddressFrom(name); // TODO
            std.initSetAdmin.assign(name, selector, implementation)
                            // .lock()
                            .dump();
            return std.finishProcess(pid);
        }

        function assignAndLoad_GetDeps(StdFunctions storage std) internal returns(StdFunctions storage) {
            uint pid = std.startProcess("assignAndLoad_GetDeps");
            string memory name = "GetDeps";
            bytes4 selector = GetDeps.getDeps.selector;
            address implementation = loadAddressFrom(name);
            std.getDeps .assign(name, selector, implementation)
                        // .lock()
                        .dump();
            return std.finishProcess(pid);
        }

        function assignAndLoad_Clone(StdFunctions storage std) internal returns(StdFunctions storage) {
            uint pid = std.startProcess("assignAndLoad_Clone");
            string memory name = "Clone";
            bytes4 selector = Clone.clone.selector;
            address implementation = loadAddressFrom(name);
            std.clone   .assign(name, selector, implementation)
                        // .lock()
                        .dump();
            return std.finishProcess(pid);
        }


    /**-----------------------------------------------
        🐣 Deploy Standard Functions If Not Exists
        TODO versioning
    -------------------------------------------------*/
    function deployIfNotExists(StdFunctions storage std) internal returns(StdFunctions storage) {
        return std  .deployIfNotExists_InitSetAdmin()
                    .deployIfNotExists_GetDeps()
                    .deployIfNotExists_Clone();
    }
        /**===== Each Std Function =====*/
        function deployIfNotExists_InitSetAdmin(StdFunctions storage std) internal returns(StdFunctions storage) {
            if (std.initSetAdmin.implementation.isNotContract()) {
                std.initSetAdmin.assignImplementation(address(new InitSetAdmin()));
            }
            return std;
        }

        function deployIfNotExists_GetDeps(StdFunctions storage std) internal returns(StdFunctions storage) {
            if (!std.getDeps.implementation.isContract()) {
                std.getDeps.assignImplementation(address(new GetDeps()));
            }
            return std;
        }

        function deployIfNotExists_Clone(StdFunctions storage std) internal returns(StdFunctions storage) {
            if (!std.clone.implementation.isContract()) {
                std.clone.assignImplementation(address(new Clone()));
            }
            return std;
        }


    /**----------------------------------
        🧺 Configure Standard Bundles
    ------------------------------------*/
    function configureStdBundle(StdFunctions storage std) internal returns(StdFunctions storage) {
        uint pid = std.startProcess("configureStdBundle");
        return std  .configureStdBundle_AllFunctions()
                    .finishProcess(pid);
    }

        /**===== Each Std Bundle =====*/
        function configureStdBundle_AllFunctions(StdFunctions storage std) internal returns(StdFunctions storage) {
            uint pid = std.startProcess("configureStdBundle_AllFunctions");
            std.all .assignName("ALL_FUNCTIONS")
                    .pushFunction(std.initSetAdmin)
                    .pushFunction(std.getDeps)
                    .pushFunction(std.clone)
                    .assignFacade(address(new StdFacade()));
            return std.finishProcess(pid);
        }

}


/****************************************************
    🧩 Std Ops Primitive Utils for Arguments
*****************************************************/
library StdFunctionsArgs {
    function initSetAdminBytes(address admin) internal view returns(bytes memory) {
        return abi.encodeCall(InitSetAdmin.initSetAdmin, admin);
    }

}
