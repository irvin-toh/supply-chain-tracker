# Supply Chain Tracker

## Description

The Supply Chain Tracker is a smart contract developed in Solidity that facilitates the management of products and orders in a supply chain environment. Users can create shop products, add items to their carts, and place orders. The contract tracks the status of orders and manages inventory.

### Key Features

#### Shop Owner:
- **Add products to a shop:** Use `createShopProduct` to add new products.
- **Update product quantities:** Modify existing product quantities with `updateProductQuantity`.
- **Remove products from the shop:** Use `deleteShopProduct` to remove items.
- **Track active and completed orders:** Monitor orders and their statuses.

#### Customer:
- **Add and remove items from a cart:** Use `addToCart` to add and `removeFromCart` to delete items.
- **Create orders from the cart:** Finalize your selections using `createOrder`.
- **Track the status of their order:** Use order IDs stored in `activeOrders` for order updates.

#### Additional Features:
- Automatically updates product quantities as orders are made.
- Status updates are handled automatically.
- Orders are removed from active listings once completed.

## Prerequisites

Before deploying the smart contract, ensure you have:
- [MetaMask](https://metamask.io/) browser extension installed and set up.
- Some test Ether in your wallet for deploying to a test network (like Goerli or Sepolia).

## Installation

1. **Open Remix:**
   - Go to [Remix IDE](https://remix.ethereum.org/).

2. **Create a New File:**
   - In Remix, create a new file and copy your Solidity code into it.

## Compilation

1. In Remix, select the Solidity compiler.
2. Ensure the compiler version is set to `0.8.18`.
3. Click the "Compile" button.

## Deployment to Testnet

1. **Connect MetaMask to a test network:**
   - Open MetaMask and switch to a test network like Goerli or Sepolia.

2. **Get Test Ether:**
   - Use a faucet to obtain test Ether for the selected network.

3. **Deploy the Contract:**
   - In Remix, go to the "Deploy & Run Transactions" tab.
   - Select "Injected Web3" as the environment to connect to MetaMask.
   - Ensure the correct account is selected in MetaMask.
   - Click the "Deploy" button and confirm the transaction in MetaMask.

4. **Interact with the Contract:**
   - After deployment, you will see your contract in Remix. You can call functions like `createShopProduct`, `addToCart`, and `createOrder`.

## Functions 

### Owner Exclusive:
- `createShopProduct(string memory _name, uint32 _quantity)`: Adds a new product to the shop.
- `deleteShopProduct(uint256 index)`: Removes a product based on its index.
- `updateProductQuantity(string memory _name, uint32 _newQuantity)`: Updates the quantity of a specified product.

### Customer:
- `addToCart(string memory _productName, uint32 _quantity)`: Adds products to the customer's cart if available.
- `removeFromCart(uint256 index)`: Removes items from the customer's cart.
- `createOrder()`: Confirms the order and updates product quantities accordingly.

### Order:
- `transferOwnership(uint256 _id, address _newOwner)`: Transfers order ownership in the supply chain.
- `finishOrder(uint256 _id)`: Finalizes the order once it reaches the customer.

### Order Tracking:
- The contract maintains a mapping of active orders through the `orders` mapping. Each order is identified by a unique `uint256` ID, which is incremented for each new order.
- The `Order` struct includes:
  - `id`: Unique identifier for the order.
  - `currentOwner`: The address of the current owner of the order (initially the shop owner).
  - `finalOwner`: The address of the customer who placed the order.
  - `status`: The current status of the order (e.g., "Preparing Order", "In Transit", "Finished Order").
  - `ownerHistory`: An array of addresses tracking the ownership history of the order.
  - `products`: An array of `Product` structs representing the items in the order.

### Active Orders:
- Customers can view their active orders by accessing the `activeOrders` mapping, which stores an array of order IDs associated with their address.
- To track the status of an order, customers should retrieve their active order IDs and use them with the `orders(uint256 _id)` function.

### Example Usage:
- **Track an order:** 
  1. Retrieve your active order IDs using `activeOrders[msg.sender]`.
  2. Use the retrieved order ID with `orders(uint256 _id)` to retrieve the current status and details of your order.

## Testing

To test the smart contract functionality, you will need three accounts:

1. **Owner Account:** This account will deploy the contract and create the shop.
2. **Customer Account:** This account will interact with the shop by adding items to the cart, creating orders, and tracking the order status.
3. **Vendor Account:** This account will act as a vendor in the supply chain, showing the change in ownership as the product moves through the supply chain.

### Testing Steps:

1. **Deploy the Contract:**
   - Use the owner account to deploy the contract.

2. **Create a Shop:**
   - The owner creates a shop using `createShopProduct`.

3. **Add Products:**
   - The owner adds products to the shop.

4. **Customer Interaction:**
   - The customer account uses `addToCart` to select items and `createOrder` to place an order.

5. **Track Order:**
   - The customer can check their order status and see who currently has their items by using the active order IDs with the `orders(uint256 _id)` function.

6. **Vendor Interaction:**
   - The owner transfers ownership of the order to the vendor account using `transferOwnership` once the product is shipped.
   - The order status will then change automatically to show that the product is 'In transit'.

7. **Final Transfer:**
   - Once the product reaches the customer, the vendor can transfer ownership to the customer.

Throughout the process, the customer can track who currently has their items and the status of the order.

## Troubleshooting

If you encounter issues:
- Ensure you have sufficient test Ether in your MetaMask wallet.
- Double-check that the correct network is selected in MetaMask.
- Make sure to follow the correct order of function calls.

## Contributing

If you wish to contribute to this project:
1. Fork the repository.
2. Create a pull request with your changes.
3. Follow the coding standards and testing guidelines provided in the repository.

## License

This project is licensed under the MIT License.
