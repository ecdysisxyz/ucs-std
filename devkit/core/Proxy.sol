// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
/**---------------------
    Support Methods
-----------------------*/
import {ProcessManager, params} from "devkit/system/debug/Process.sol";
import {Inspector} from "devkit/types/Inspector.sol";
import {TypeGuard, TypeStatus} from "devkit/types/TypeGuard.sol";
// Validation
import {Validate} from "devkit/system/Validate.sol";

// External Lib Contract
import {Proxy as UCSProxy} from "@ucs.mc/proxy/Proxy.sol";
// Mock Contract
import {ProxySimpleMock} from "devkit/mocks/ProxySimpleMock.sol";

// Core Types
import {Dictionary} from "devkit/core/Dictionary.sol";
import {Function} from "devkit/core/Function.sol";


///////////////////////////////////////////
//  🏠 Proxy   ////////////////////////////
    using ProxyLib for Proxy global;
    using ProcessManager for Proxy global;
    using Inspector for Proxy global;
    using TypeGuard for Proxy global;
///////////////////////////////////////////
struct Proxy {
    address addr;
    ProxyKind kind;
    TypeStatus status;
}
library ProxyLib {
    /**---------------------
        🚀 Deploy Proxy
    -----------------------*/
    function deploy(Dictionary memory dictionary, bytes memory initData) internal returns(Proxy memory proxy) {
        uint pid = proxy.startProcess("deploy", params(dictionary, initData));
        Validate.MUST_Completed(dictionary);
        proxy.startBuilding();
        proxy.addr = address(new UCSProxy(dictionary.addr, initData));
        proxy.kind = ProxyKind.Verifiable;
        proxy.finishBuilding();
        return proxy.finishProcess(pid);
    }

    /**--------------------------
        🤖 Create Proxy Mock
    ----------------------------*/
    function createSimpleMock(Function[] memory functions) internal returns(Proxy memory proxy) {
        uint pid = proxy.startProcess("createSimpleMock", params(functions));
        for (uint i; i < functions.length; ++i) {
            Validate.MUST_Completed(functions[i]);
        }
        proxy.startBuilding();
        proxy.addr = address(new ProxySimpleMock(functions));
        proxy.kind = ProxyKind.Mock;
        proxy.finishBuilding();
        return proxy.finishProcess(pid);
    }

}


/**---------------
    Proxy Kind
-----------------*/
enum ProxyKind {
    undefined,
    Normal,
    Verifiable,
    Mock
}
using Inspector for ProxyKind global;
