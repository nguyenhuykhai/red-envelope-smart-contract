// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract RandomHelper {
    /**
     * @dev Generates a pseudo-random number based on `remainingAmount`, `block.timestamp`, and `block.difficulty`.
     * @param remainingAmount The upper limit for the random number.
     * @return uint256 A pseudo-random number.
     */
    function random(uint256 remainingAmount) internal view returns (uint256) {
        require(remainingAmount > 0, "RandomHelper: remainingAmount must be greater than 0");

        // Generate a pseudo-random number using block.timestamp, block.prevrandao, and remainingAmount
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    remainingAmount,
                    msg.sender // Add msg.sender to increase entropy
                )
            )
        );

        // Reduce bias by using a loop to discard values outside the desired range
        uint256 threshold = type(uint256).max - (type(uint256).max % remainingAmount);
        while (randomNumber >= threshold) {
            randomNumber = uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        remainingAmount,
                        msg.sender,
                        randomNumber // Add previous randomNumber to increase entropy
                    )
                )
            );
        }

        return randomNumber % remainingAmount;
    }

    /**
     * @dev Wrapper function for `random`.
     * @param maxAmount The upper limit for the random number.
     * @return uint256 A pseudo-random number.
     */
    function getRandomNumber(uint256 maxAmount) public view returns (uint256) {
        require(maxAmount > 0, "RandomHelper: maxAmount must be greater than 0");
        return random(maxAmount);
    }

    /**
     * @dev Compares two strings.
     * @param a The first string.
     * @param b The second string.
     * @return bool True if the strings are equal, false otherwise.
     */
    function stringsEqual(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}