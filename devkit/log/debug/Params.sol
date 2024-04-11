// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {StringUtils} from "devkit/utils/primitive/StringUtils.sol";
    using StringUtils for string;
import {AddressUtils} from "devkit/utils/primitive/AddressUtils.sol";
    using AddressUtils for address;
import {Bytes4Utils} from "devkit/utils/primitive/Bytes4Utils.sol";
    using Bytes4Utils for bytes4;


library Params {
    string constant HEADER = " with params: ";

    // 1 param
    function append(string memory str) internal returns(string memory) {
        return HEADER.append(str);
    }

    // 2 params
    function append(string memory str, string memory str2) internal returns(string memory) {
        return HEADER.append(str).comma().append(str2);
    }
    function append(string memory str, bytes memory b) internal returns(string memory) {
        return append(str, string(b));
    }
    function append(string memory str, address addr) internal returns(string memory) {
        return append(str, addr.toString());
    }
    function append(address addr, bytes memory b) internal returns(string memory) {
        return append(addr.toString(), string(b));
    }
    function append(bytes4 b4, address addr) internal returns(string memory) {
        return append(b4.toString(), addr.toString());
    }

    // 3 params
    function append(string memory str, bytes4 b4, address addr) internal returns(string memory) {
        return HEADER.append(str).comma().append(b4).comma().append(addr);
    }
    function append(string memory str, string memory str2, address addr) internal returns(string memory) {
        return HEADER.append(str).comma().append(str2).comma().append(addr);
    }

}