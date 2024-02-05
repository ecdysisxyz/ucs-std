// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface IGetDepsOp {
    struct Op {
        bytes4 selector;
        address implementation;
    }

    function getDeps() external view returns(Op[] memory ops);
}
