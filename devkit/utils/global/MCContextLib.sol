// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKit} from "devkit/MCDevKit.sol";


/***********************************************
    🎭 Context
        ♻️ Reset Current Context
************************************************/
library MCContextLib {

    /**-----------------------------
        ♻️ Reset Current Context
    -------------------------------*/
    function reset(MCDevKit storage mc) internal returns(MCDevKit storage) {
        uint pid = mc.startProcess("reset");
        mc.bundle.current.reset();
        mc.functions.current.reset();
        mc.dictionary.current.reset();
        mc.proxy.current.reset();
        return mc.finishProcess(pid);
    }

}
