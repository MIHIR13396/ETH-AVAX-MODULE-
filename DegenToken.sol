/* our task is to create a ERC20 token and deploy it on the Avalanche network for Degen Gaming. The smart contract should have the following functionality:

Minting new tokens: The platform should be able to create new tokens and distribute them to players as rewards. Only the owner can mint tokens.
Transferring tokens: Players should be able to transfer their tokens to others.
Redeeming tokens: Players should be able to redeem their tokens for items in the in-game store.
Checking token balance: Players should be able to check their token balance at any time.
Burning tokens: Anyone should be able to burn tokens, that they own, that are no longer needed.

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract DegenToken is ERC20, Ownable, ERC20Burnable {
    struct Item {
        string name;
        uint256 cost;
        bool available;
    }

    mapping(uint256 => Item) public items;
    mapping(address => mapping(uint256 => uint256)) public playerItems;
    uint256 public nextItemId;

    event ItemAdded(uint256 itemId, string name, uint256 cost);
    event ItemUpdated(uint256 itemId, string name, uint256 cost);
    event ItemRemoved(uint256 itemId);
    event ItemRedeemed(address indexed player, uint256 itemId, uint256 cost, uint256 quantity);

    constructor(address initialOwner) ERC20("Degen", "DGN") Ownable(initialOwner) {
        nextItemId = 1; // Start item IDs from 1 for better readability
    }

    // Mint new tokens, only owner can call this function
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Override decimals to return 0
    function decimals() public pure override returns (uint8) {
        return 0;
    }

    // Function to get the balance of the caller
    function getBalance() external view returns (uint256) {
        return balanceOf(msg.sender);
    }

    // Function to transfer tokens from the caller to another address
    function transferTokens(address receiver, uint256 value) external {
        require(balanceOf(msg.sender) >= value, "You do not have enough Degen Tokens");
        transfer(receiver, value);
    }

    // Function to burn tokens, callable by anyone
    function burnTokens(uint256 value) external {
        require(balanceOf(msg.sender) >= value, "You do not have enough Degen Tokens");
        burn(value);
    }

    // Function to add a new item to the store, only owner can call this
    function addItem(string memory name, uint256 cost) public onlyOwner {
        items[nextItemId] = Item(name, cost, true);
        emit ItemAdded(nextItemId, name, cost);
        nextItemId++;
    }

    // Function to update an existing item in the store, only owner can call this
    function updateItem(uint256 itemId, string memory name, uint256 cost) public onlyOwner {
        require(items[itemId].available, "Item does not exist");
        items[itemId] = Item(name, cost, true);
        emit ItemUpdated(itemId, name, cost);
    }

    // Function to remove an item from the store, only owner can call this
    function removeItem(uint256 itemId) public onlyOwner {
        require(items[itemId].available, "Item does not exist");
        items[itemId].available = false;
        emit ItemRemoved(itemId);
    }

    // Function to redeem tokens for in-game items by burning them
    function redeemTokens(uint256 itemId, uint256 quantity) external {
        require(items[itemId].available, "Item is not available");
        uint256 totalCost = items[itemId].cost * quantity;
        require(balanceOf(msg.sender) >= totalCost, "You do not have enough Degen Tokens");
        burn(totalCost);
        playerItems[msg.sender][itemId] += quantity;
        emit ItemRedeemed(msg.sender, itemId, totalCost, quantity);
    }

    // Function to get details of an item
    function getItem(uint256 itemId) external view returns (string memory name, uint256 cost, bool available) {
        require(items[itemId].available, "Item does not exist");
        Item memory item = items[itemId];
        return (item.name, item.cost, item.available);
    }

    // Function to get all items in the store
    function getAllItems() external view returns (Item[] memory) {
        uint256 itemCount = 0;
        for (uint256 i = 1; i < nextItemId; i++) {
            if (items[i].available) {
                itemCount++;
            }
        }

        Item[] memory availableItems = new Item[](itemCount);
        uint256 index = 0;
        for (uint256 i = 1; i < nextItemId; i++) {
            if (items[i].available) {
                availableItems[index] = items[i];
                index++;
            }
        }

        return availableItems;
    }

    // Function to get the quantity of a specific item a player owns
    function getPlayerItemQuantity(address player, uint256 itemId) external view returns (uint256) {
        return playerItems[player][itemId];
    }
}
