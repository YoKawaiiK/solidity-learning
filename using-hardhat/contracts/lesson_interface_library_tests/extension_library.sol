// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

library StringExtension {
    function eq(string memory str1, string memory str2)
        external
        pure
        returns (bool)
    {
        return keccak256(abi.encode(str1)) == keccak256(abi.encode(str2));
    }
}

library ArrayExtension {
    function inArray(uint[] memory arr, uint el) external pure returns (bool) {
        for (uint i = 0; i < arr.length; i++) {
            if (arr[i] == el) {
                return true;
            }
        }
        return false;
    }
}
