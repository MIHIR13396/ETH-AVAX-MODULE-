# DegenToken

## Description

`DegenToken` is a Solidity smart contract that implements an ERC20 token named "Degen" (symbol: "DGN") on the Ethereum blockchain. It includes additional functionalities for managing an item store where tokens can be redeemed for in-game items. This README provides an overview of its features and how to interact with it.

## Getting Started

### Prerequisites

- Ensure you have access to an Ethereum-compatible wallet (e.g., MetaMask).
- Connect to an Ethereum network (e.g., Ropsten, Rinkeby) using Remix or a similar development environment.

### Installation

To interact with `DegenToken`:

1. **Set up Remix**
   - Visit [Remix](https://remix.ethereum.org/).
   - Create a new Solidity file, e.g., `DegenToken.sol`.

2. **Copy and Paste Code**
   - Insert the contract code into `DegenToken.sol`.

3. **Compile and Deploy**
   - Compile the code using the "Solidity Compiler" tab.
   - Deploy the contract using the "Deploy & Run Transactions" tab.

### Contract Code

```solidity

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

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
    uint256 public nextItemId;

    event ItemAdded(uint256 itemId, string name, uint256 cost);
    event ItemUpdated(uint256 itemId, string name, uint256 cost);
    event ItemRemoved(uint256 itemId);
    event ItemRedeemed(address indexed player, uint256 itemId, uint256 cost);

    constructor() ERC20("Degen", "DGN") Ownable(msg.sender) {
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
    function redeemTokens(uint256 itemId) external {
        require(items[itemId].available, "Item is not available");
        uint256 cost = items[itemId].cost;
        require(balanceOf(msg.sender) >= cost, "You do not have enough Degen Tokens");
        burn(cost);
        emit ItemRedeemed(msg.sender, itemId, cost);
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
}
```

## Usage

### Minting Tokens

Only the contract owner can mint new tokens.

```solidity
function mint(address to, uint256 amount) public onlyOwner {
    _mint(to, amount);
}
```
### Transferring Tokens
Transfer tokens to another address.

```solidity
function transferTokens(address receiver, uint256 value) external {
    require(balanceOf(msg.sender) >= value, "You do not have enough Degen Tokens");
    transfer(receiver, value);
}
```
### Burning Tokens
Burn tokens, reducing the total supply.

```solidity
function burnTokens(uint256 value) external {
    require(balanceOf(msg.sender) >= value, "You do not have enough Degen Tokens");
    burn(value);
}
```
### Managing Store Items
Owners can add, update, and remove items in the store.

```solidity
function addItem(string memory name, uint256 cost) public onlyOwner {
    items[nextItemId] = Item(name, cost, true);
    emit ItemAdded(nextItemId, name, cost);
    nextItemId++;
}

function updateItem(uint256 itemId, string memory name, uint256 cost) public onlyOwner {
    require(items[itemId].available, "Item does not exist");
    items[itemId] = Item(name, cost, true);
    emit ItemUpdated(itemId, name, cost);
}

function removeItem(uint256 itemId) public onlyOwner {
    require(items[itemId].available, "Item does not exist");
    items[itemId].available = false;
    emit ItemRemoved(itemId);
}
```
### Redeeming Tokens for Items
Users can redeem tokens for in-game items by burning them.

```solidity
function redeemTokens(uint256 itemId) external {
    require(items[itemId].available, "Item is not available");
    uint256 cost = items[itemId].cost;
    require(balanceOf(msg.sender) >= cost, "You do not have enough Degen Tokens");
    burn(cost);
    emit ItemRedeemed(msg.sender, itemId, cost);
}
```
### Retrieving Item Information
Retrieve details of items in the store.

```solidity
function getItem(uint256 itemId) external view returns (string memory name, uint256 cost, bool available) {
    require(items[itemId].available, "Item does not exist");
    Item memory item = items[itemId];
    return (item.name, item.cost, item.available);
}
```
### Retrieving All Available Items
Get a list of all available items in the store.

```solidity
function getAllItems() external view returns (Item[] memory) {
    // Implementation details...
}
```

## Testing on Avalanche Fuji Testnet

After deployment, test the contract on Avalanche Fuji Testnet:

1. **Use Tools**: Use tools like Remix or Truffle console to interact with the deployed contract.
   
2. **Execute Transactions**: Execute transactions to perform the following actions:
   - Mint tokens using the `mint` function.
   - Transfer tokens using the `transferTokens` function.
   - Manage store items by adding, updating, or removing items using `addItem`, `updateItem`, and `removeItem`.
   - Redeem tokens for items using the `redeemTokens` function.
   - Retrieve item information using the `getItem` and `getAllItems` functions.

3. **Functionalities Verification**: Verify that all functionalities behave as expected by checking balances, item availability, and token transfers.

## Verifying the Smart Contract on Snowtrace

To verify the contract on Snowtrace:

1. **Obtain Contract Address**: After deploying the contract on Avalanche Fuji Testnet, obtain the contract address from the deployment transaction.

2. **Visit Snowtrace**: Go to [Snowtrace](https://snowtrace.io/).

3. **Verify Contract Details**:
   - Enter the contract address in the search bar on Snowtrace.
   - Verify contract details including source code, functions, events, and contract status.

## Sharing the Smart Contract

Share the smart contract details with stakeholders for integration and use:
   
- **Contract Address**: Provide the deployed contract address on Avalanche Fuji Testnet.
- **ABI (Application Binary Interface)**: Share the ABI JSON file or the ABI text format for easy integration with frontend applications or other contracts.


## Authors

MIHIR  
[@MIHIR SINGH](www.linkedin.com/in/mihir-singh-0974832a8)


## License

This project is licensed under the MIT License - see the LICENSE.md file for details
