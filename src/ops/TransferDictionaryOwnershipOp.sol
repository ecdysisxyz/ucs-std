// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

// storage
import {StorageLib} from "../StorageLib.sol";
import {ITransferDictionaryOwnershipOp} from "../interfaces/ops/ITransferDictionaryOwnershipOp.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IDictionary} from "@ucs-contracts/src/dictionary/IDictionary.sol";
import {ERC7546Utils} from "@ucs-contracts/src/proxy/ERC7546Utils.sol";

// predicates
import {MsgSender} from "../predicates/MsgSender.sol";

contract TransferDictionaryOwnershipOp is ITransferDictionaryOwnershipOp {
    /// DO NOT USE STORAGE DIRECTLY !!!

    modifier requires() {
        MsgSender.shouldBeAdmin();
        _;
    }

    modifier intents() {
        _;
    }

    function transferDictionaryOwnership(address newOwner) external requires intents {
        Ownable(ERC7546Utils.getDictionary()).transferOwnership(newOwner);
    }
}
