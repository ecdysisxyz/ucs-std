// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FunctionLib} from "./FunctionLib.sol";
import {ProcessLib} from "devkit/debug/ProcessLib.sol";
import {LogLib} from "devkit/debug/LogLib.sol";


/**==================
    🧩 Function
====================*/
struct Function { /// @dev Function may be different depending on the op version.
    string name;
    bytes4 selector;
    address implementation;
}
using FunctionLib for Function global;
using ProcessLib for Function global;
using LogLib for Function global;
