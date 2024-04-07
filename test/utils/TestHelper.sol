// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AddressUtils} from "devkit/utils/AddressUtils.sol";
    using AddressUtils for address;
import {StringUtils} from "devkit/utils/StringUtils.sol";
    using StringUtils for string;

import {Function} from "devkit/core/functions/Function.sol";
// import {Bundle} from "./Bundle.sol";

import {InitSetAdmin} from "mc-std/functions/protected/InitSetAdmin.sol";
import {GetDeps} from "mc-std/functions/GetDeps.sol";
import {Clone} from "mc-std/functions/Clone.sol";

library TestHelper {
    function isInitSetAdmin(Function memory functionInfo) internal returns(bool) {
        return
            functionInfo.name.isEqual("InitSetAdmin") &&
            functionInfo.selector == InitSetAdmin.initSetAdmin.selector &&
            functionInfo.implementation.isContract();
    }

    function isGetDeps(Function memory functionInfo) internal returns(bool) {
        return
            functionInfo.name.isEqual("GetDeps") &&
            functionInfo.selector == GetDeps.getDeps.selector &&
            functionInfo.implementation.isContract();
    }

    function isClone(Function memory functionInfo) internal returns(bool) {
        return
            functionInfo.name.isEqual("Clone") &&
            functionInfo.selector == Clone.clone.selector &&
            functionInfo.implementation.isContract();
    }
}
