// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";

contract NetworkConfig {
    error NetworkConfig__ChainIdNotSupported(uint256 chainId);

    AggregatorV3Interface private s_priceFeed;
    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 private constant KAIROS_CHAIN_ID = 1001;
    uint8 private constant MOCK_DECIMALS_KAIROS_CHAIN = 8;
    int256 private constant MOCK_PRICE_KAIROS_CHAIN = 0.2e8; // 0.2 USD
    uint8 private constant MOCK_DECIMALS = 8;
    int256 private constant MOCK_PRICE = 2e8; // 2 USD

    constructor() {
        uint256 chainId = block.chainid;

        if (chainId == SEPOLIA_CHAIN_ID) {
            // Sepolia ETH/USD Price Feed
            s_priceFeed = AggregatorV3Interface(
                0x694AA1769357215DE4FAC081bf1f309aDC325306
            );
        } else if (chainId == KAIROS_CHAIN_ID) {
            // Kairos ETH/USD Price Feed
            MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
                MOCK_DECIMALS_KAIROS_CHAIN,
                MOCK_PRICE_KAIROS_CHAIN
            );
            s_priceFeed = AggregatorV3Interface(address(mockPriceFeed));
        } else {
            // Local network - deploy mock
            MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
                MOCK_DECIMALS,
                MOCK_PRICE
            );
            s_priceFeed = AggregatorV3Interface(address(mockPriceFeed));
        }
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }

    function getLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = s_priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        return uint256(price);
    }

    /**
     * Lấy giá ETH/USD mới nhất và chuyển đổi thành Wei
     */
    function getLatestPriceInWei() public view returns (uint256) {
        (, int256 price, , , ) = s_priceFeed.latestRoundData();

        // Chuyển đổi giá từ USD với độ chính xác 8 chữ số thành Wei
        // 1 ETH = 10^18 Wei, do đó cần nhân với 10^10 để điều chỉnh từ 10^8 lên 10^18
        uint256 priceInWei = uint256(price) * 1e10;
        return priceInWei;
    }

    function getDecimals() public view returns (uint8) {
        return s_priceFeed.decimals();
    }

    function getDescription() public view returns (string memory) {
        return s_priceFeed.description();
    }
}
