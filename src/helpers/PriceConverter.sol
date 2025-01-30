// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract PriceConverter {
    uint256 public constant PRICE_DECIMALS = 18;
    uint256 public constant PRICE_BASE = 10 ** PRICE_DECIMALS;

    function convertToPrice(uint256 amount) public pure returns (uint256) {
        return amount * PRICE_BASE;
    }

    function convertToAmount(uint256 price) public pure returns (uint256) {
        return price / PRICE_BASE;
    }
}
