// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {MCTest, console, ForgeHelper, Dummy, DummyFunction, DummyFacade} from "@mc-devkit/Flattened.sol";

import {GetFunctions} from "@mc-std/functions/GetFunctions.sol";
import {ProxyCreator} from "@mc-std/functions/internal/ProxyCreator.sol";

contract GetFunctionsTest is MCTest {
    function setUp() public {
        _use(GetFunctions.getFunctions.selector, address(new GetFunctions()));
        _use(DummyFunction.dummy.selector, address(new DummyFunction()));
        _use(DummyFunction.dummy2.selector, address(new DummyFunction()));
        _setDictionary(Dummy.dictionary(mc, functions));
    }

    function test_GetFunctions_Success() public view {
        GetFunctions.Function[] memory funcs = GetFunctions(target).getFunctions();
        for (uint256 i; i < funcs.length; ++i) {
            assertEq(funcs[i].selector, functions[i].selector);
            assertEq(funcs[i].implementation, functions[i].implementation);
        }
    }
}
