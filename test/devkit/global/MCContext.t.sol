// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKitTest} from "devkit/MCTest.sol";

import {Inspector} from "devkit/types/Inspector.sol";
    using Inspector for string;

import {MessageHead as HEAD} from "devkit/system/message/MessageHead.sol";

contract DevKitTest_MCContext is MCDevKitTest {
    /**-----------------------------
        ♻️ Reset Current Context
    -------------------------------*/
    function test_reset_Success() public {
        mc.functions.current.name = "Current Function";
        mc.bundle.current.name = "Current Bundle";
        mc.dictionary.current.name = "Current Dictionary";
        mc.proxy.current.name = "Current Proxy";

        mc.reset();

        assertTrue(mc.functions.current.name.isEmpty());
        assertTrue(mc.bundle.current.name.isEmpty());
        assertTrue(mc.dictionary.current.name.isEmpty());
        assertTrue(mc.proxy.current.name.isEmpty());
    }

}