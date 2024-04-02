// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {console2} from "forge-std/console2.sol";
import {MCTest} from "devkit/MCTest.sol";
import {Clone} from "bundle/std/functions/Clone.sol";

contract StdTest is MCTest {
    function setUp() public startPrankWith("TEST_DEPLOYER") {
        // address proxy = ucs .deploy("MyProxy")
        //                     .set(mc.functions.stdOps.clone)
        //                     .getProxy().toAddress();
        // CloneOp(proxy).clone("");

        // mc.createMockDictionary();
        // mc.createMockDictionary();
        // mc.createSimpleMockProxy();
        // mc.createMockDictionary();
        // mc.createMockDictionary();

        // mc.setCustomFunction({
        //     keyword: "Clone",
        //     selector: CloneOp.clone.selector,
        //     deployedContract: address(new CloneOp())
        // });
        // ucs .createCustomBundle("MyOps")
        //     .add("Clone")
        //     .add(mc.functions.stdOps.defaultOps)
        //     .add({
        //         keyword: "Clone",
        //         selector: CloneOp.clone.selector,
        //         deployedContract: address(new CloneOp())
        //     });
        // address myProxy = mc.deploy(mc.getBundle("MyOps")).getProxyAddress();
        // CloneOp(myProxy).clone("");

        // address ourProxy = ucs  .use("Clone")
        //                         .use(mc.functions.stdOps.defaultOps)
        //                         .use({
        //                             keyword: "Clone",
        //                             selector: CloneOp.clone.selector,
        //                             deployedContract: address(new CloneOp())
        //                         })
        //                         .deploy().getProxyAddress();
        vm.deal(deployer, 100 ether);

        address multisigAddr;

mc.startDebug();

        address yamato = mc .init("Yamato")
                            .use("Borrower", YamatoBorrower.borrow.selector, address(new YamatoBorrower()))
                            .use("Depositor", YamatoDepositor.deposit.selector, address(new YamatoDepositor()))
                            // .use("Redeemer")
                            // .use("Repayer")
                            // .use("Sweeper")
                            // .use("Withdrawer")
                            .use("Initialize", YamatoInitialize.initialize.selector, address(new YamatoInitialize()))
                            .set("Yamato", address(new YamatoFacade()))
                            .deploy(abi.encodeCall(YamatoInitialize.initialize, multisigAddr))
                            .toProxyAddress();

        // console2(YamatoBorrower.borrow);
        // TODO keyword --> selector
        // string.concat(type(YamatoBorrower).name, YamatoBorrower.borrow.selector)

        IYamato(yamato).deposit{value: 1 ether}();



        // address proxy = ucs .findDictionary("Default")
        //                     .deployProxy("MyProxy");
        // address proxy = ucs .deployDictionary("Default")
        //                     .deployProxy("MyProxy");
    }

    function test_Success_DeployNewProxy() public {
    }
}

contract YamatoBorrower {
    function borrow() public {}
}
contract YamatoDepositor {
    function deposit() public payable {}
}
contract YamatoInitialize {
    function initialize(address governance) public {}
}
interface IYamato {
    function borrow() external;
    function deposit() external payable;
}
contract YamatoFacade {
    function borrow() external {}
    function deposit() external payable {}
}
