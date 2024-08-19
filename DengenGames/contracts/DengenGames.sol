// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error NotEnoughDegen(string message, uint requiredAmount);

contract DegenClone is ERC20, Ownable {
    enum RedeemItems {
        Drum_sticks,
        Pedal,
        Key,
        Drum_pad
    }

    mapping(address => string[]) private _redeemedItems;

    constructor() ERC20("Degen", "DGN") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function transferDegen(
        address to,
        uint256 amount
    ) external returns (bool success) {
        if (amount < balanceOf(msg.sender)) {
            revert NotEnoughDegen("Degen Token not enough", amount);
        }
        success = transfer(to, amount);
    }

    function burn(uint256 amount) external {
        if (amount < balanceOf(msg.sender)) {
            revert NotEnoughDegen("Degen Token not enough", amount);
        }
        _burn(msg.sender, amount);
    }

    function redeemItems(RedeemItems item) external {
        uint256 price = 0;
        if (item == RedeemItems.Drum_sticks) {
            price = 4 * 1e18;
        } else if (item == RedeemItems.Pedal) {
            price = 3 * 1e18;
        } else if (item == RedeemItems.Key) {
            price = 2 * 1e18;
        } else if (item == RedeemItems.Drum_pad) {
            price = 1 * 1e18;
        } else {
            price = 0;
        }

        if (price > balanceOf(msg.sender)) {
            revert NotEnoughDegen("Degen Token not enough", price);
        }
        // take the token used to redeem the item out of circulation by burning it
        _burn(msg.sender, price);

        // Record the redeemed item
        string[] storage currentRedeemedItems = _redeemedItems[msg.sender];
        currentRedeemedItems.push(_itemToString(item));
    }

    function withdrawFunds() external onlyOwner {
        _transfer(address(this), msg.sender, balanceOf(address(this)));
    }

    function getBalance() public view returns (uint256) {
        return balanceOf(msg.sender);
    }

    function _itemToString(
        RedeemItems item
    ) internal pure returns (string memory) {
        if (item == RedeemItems.Drum_sticks) {
            return "Drum_sticks";
        } else if (item == RedeemItems.Pedal) {
            return "Pedal";
        } else if (item == RedeemItems.Key) {
            return "Key";
        } else if (item == RedeemItems.Drum_pad) {
            return "Drum_pad";
        } else {
            return "";
        }
    }

    function displayRedeemedItems(
        address user
    ) public view returns (string[] memory) {
        return _redeemedItems[user];
    }
}
