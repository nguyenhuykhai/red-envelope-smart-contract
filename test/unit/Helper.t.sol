// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Helper} from "../../script/Helper.s.sol";
import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";

contract HelperTest is Test {
    Helper public helper;
    MockV3Aggregator public mockPriceFeed;

    function setUp() public {
        helper = new Helper();
        // Tạo mock Price Feed với giá trị ban đầu là 2000 * 1e8
        mockPriceFeed = new MockV3Aggregator(8, 2000 * 1e8);
    }

    // Test case 1: Local network (mock data)
    function testLocalNetwork() public {
        // Thiết lập Chain ID cho local network
        vm.chainId(31337);

        // Chạy script và kiểm tra giá trị trả về
        uint256 price = helper.run();
        assertEq(price, 2000 * 1e8);
    }

    // Test case 2: Sepolia testnet (real-time data)
    function testSepoliaNetwork() public {
        // Thiết lập Chain ID cho Sepolia
        vm.chainId(11155111); // Sepolia testnet

        // Gán địa chỉ Price Feed bằng hàm setter
        helper.setPriceFeedAddress(address(mockPriceFeed));

        // Cập nhật giá trị mock
        mockPriceFeed.updateAnswer(1800 * 1e8);

        // Chạy script và kiểm tra giá trị trả về
        uint256 price = helper.run();
        assertEq(price, 1800 * 1e8); // Kiểm tra giá trị thực tế
    }

    // Test case 3: Kairos testnet (real-time data)
    function testKairosNetwork() public {
        // Thiết lập Chain ID cho Kairos testnet
        vm.chainId(1001); // Chain ID của Kairos testnet

        // Gán địa chỉ Price Feed bằng hàm setter
        helper.setPriceFeedAddress(address(mockPriceFeed));

        // Cập nhật giá trị mock
        mockPriceFeed.updateAnswer(1500 * 1e8);

        // Chạy script và kiểm tra giá trị trả về
        uint256 price = helper.run();
        assertEq(price, 1500 * 1e8);
    }
}
