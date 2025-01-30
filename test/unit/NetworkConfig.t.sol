// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/helpers/NetworkConfig.sol";

contract NetworkConfigTest is Test {
    NetworkConfig private networkConfig;

    function setUp() public {
        // Deploy the NetworkConfig contract
        networkConfig = new NetworkConfig();
    }

    function testGetPriceFeed() public view {
        // Test that the price feed is correctly set based on the chain ID
        AggregatorV3Interface priceFeed = networkConfig.getPriceFeed();
        assertTrue(
            address(priceFeed) != address(0),
            "Price feed address should not be zero"
        );
    }

    function testGetLatestPrice() public view {
        // Test fetching the latest price from the price feed
        uint256 latestPrice = networkConfig.getLatestPriceInWei();
        assertTrue(latestPrice > 0, "Latest price should be greater than zero");
    }

    function testGetDecimals() public view {
        // Test fetching the decimals from the price feed
        uint8 decimals = networkConfig.getDecimals();
        assertTrue(decimals > 0, "Decimals should be greater than zero");
    }

    function testGetDescription() public view {
        // Test fetching the description from the price feed
        string memory description = networkConfig.getDescription();
        assertTrue(
            bytes(description).length > 0,
            "Description should not be empty"
        );
    }

    function testLocalNetworkMockPriceFeed() public {
        // Test the mock price feed on a local network (Anvil)
        vm.chainId(31337); // Anvil local network chain ID
        NetworkConfig localNetworkConfig = new NetworkConfig();

        uint256 latestPrice = localNetworkConfig.getLatestPriceInWei();
        console.log("Local Network Latest price:", latestPrice);
        assertEq(latestPrice, 2e18, "Mock price should be 2e18");

        uint8 decimals = localNetworkConfig.getDecimals();
        assertEq(decimals, 8, "Mock decimals should be 8");

        string memory description = localNetworkConfig.getDescription();
        assertEq(
            description,
            "v0.8/tests/MockV3Aggregator.sol",
            "Mock description should be 'Mock Price Feed'"
        );
    }

    function testSepoliaNetworkPriceFeed() public {
        // Test the Sepolia network price feed
        vm.chainId(11155111); // Sepolia chain ID
        NetworkConfig sepoliaNetworkConfig = new NetworkConfig();

        uint256 latestPrice = sepoliaNetworkConfig.getLatestPriceInWei();
        console.log("Sepolia latest price:", latestPrice);
        assertTrue(
            latestPrice > 0,
            "Sepolia latest price should be greater than zero"
        );

        uint8 decimals = sepoliaNetworkConfig.getDecimals();
        assertTrue(
            decimals > 0,
            "Sepolia decimals should be greater than zero"
        );

        string memory description = sepoliaNetworkConfig.getDescription();
        assertTrue(
            bytes(description).length > 0,
            "Sepolia description should not be empty"
        );
    }

    function testKairosNetworkPriceFeed() public {
        // Test the Kairos network price feed
        vm.chainId(1001);
        NetworkConfig kairosNetworkConfig = new NetworkConfig();

        uint256 latestPrice = kairosNetworkConfig.getLatestPriceInWei();
        console.log("Kairos latest price:", latestPrice);
        assertTrue(
            latestPrice > 0,
            "Kairos latest price should be greater than zero"
        );

        uint8 decimals = kairosNetworkConfig.getDecimals();
        assertTrue(decimals > 0, "Kairos decimals should be greater than zero");

        string memory description = kairosNetworkConfig.getDescription();
        assertTrue(
            bytes(description).length > 0,
            "Kairos description should not be empty"
        );
    }
}
