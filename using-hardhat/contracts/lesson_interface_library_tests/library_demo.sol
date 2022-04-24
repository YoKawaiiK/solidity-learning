// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import {StringExtension, ArrayExtension} from "./extension_library.sol";

contract LibraryDemo {
    using StringExtension for string;
    using ArrayExtension for uint[];

    function runnerString(string memory _str1, string memory _str2)
        public
        pure
        returns (bool)
    {
        // Another: StringExtension.eq(str1, str2);
        return _str1.eq(_str2);
    }

    function runnerArray(uint[] memory _array, uint _el)
        public
        pure
        returns (bool)
    {
        return _array.inArray(_el);
    }
}
