// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract Helper is Script {
    // Địa chỉ của ChainLink Price Feed cho Kaia coin (ví dụ: ETH/USD trên Sepolia)
    address public priceFeedAddress;
    AggregatorV3Interface internal _datafeed;

    // Hàm setter cho priceFeedAddress
    function setPriceFeedAddress(address _priceFeedAddress) public {
        priceFeedAddress = _priceFeedAddress;
        _datafeed = AggregatorV3Interface(_priceFeedAddress); // Khởi tạo _datafeed
    }

    // Hàm chạy script và trả về giá trị của chain
    function run() external returns (uint256) {
        // Kiểm tra mạng hiện tại
        uint256 chainId = block.chainid;

        // Case 1: Local network (ví dụ: Hardhat hoặc Anvil)
        if (chainId == 31337 || chainId == 1337) {
            return 2000 * 1e8;
        }
        // Case 2: Testnet (ví dụ: Sepolia)
        else if (chainId == 11155111) {
            // Chain ID của Sepolia
            priceFeedAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306; // Địa chỉ Price Feed ETH/USD trên Sepolia
            return getLatestPrice();
        }
        // Case 3: Kairos testnet
        else if (chainId == 1001) {
            // Chain ID của Kairos testnet
            priceFeedAddress = 0x7f003178060af3904b8b70fEa066AEE28e85043E; // Địa chỉ Price Feed trên Kairos
            return getLatestPrice();
        }
        // Case khác: Mạng không được hỗ trợ
        else {
            revert("Unsupported network");
        }
    }

    // Hàm lấy giá trị từ ChainLink Price Feed
    function getLatestPrice() internal view returns (uint256) {
        require(priceFeedAddress != address(0), "Price feed address not set");

        (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = _datafeed.latestRoundData(); // Sử dụng _datafeed thay vì tạo mới

        // Kiểm tra dữ liệu trả về
        require(answer > 0, "Invalid price");
        require(updatedAt > 0, "Price feed not updated");

        // Trả về giá trị (chuyển đổi từ int256 sang uint256)
        return uint256(answer);
    }
}
