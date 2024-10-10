    // SPDX-License-Identifier: MIT

    pragma solidity ^0.8.18;

    contract SupplyChainTracker {
        address public immutable owner;

        constructor() {
            owner = msg.sender; // Contract deployer is the initial owner
        }

        struct Product {
            string name;
            uint32 quantity;
        }

        struct Order {
            uint256 id;
            address currentOwner;
            address finalOwner;
            string status;
            address[] ownerHistory;
            Product[] products;
        }

        uint256 public orderCount = 0; // Active orders
        uint256 public totalOrderId = 0; // All orders, including completed ones

        mapping(uint256 => Order) public orders;
        mapping(address => Product[]) public carts;
        mapping(address => Product[]) public shop; // Mapping of shop owners to their products
        mapping(address => uint256[]) public activeOrders; // Mapping of customer address to their active order IDs
        Order[] public completedOrders;

        event OrderAdded(uint256 id, string status, address owner, Product[] products);
        event OwnershipTransferred(uint256 id, address from, address to);
        event OrderCompleted(uint256 id);
        event CartCleared(address user);
        event ProductAdded(address shopOwner, string productName, uint32 quantity);
        event ProductDeleted(address shopOwner, string productName);
        event ProductUpdated(address shopOwner, string productName, uint32 newQuantity);

        modifier onlyOwner() {
            require(msg.sender == owner, "Only the contract owner can perform this action.");
            _;
        }

        // Shop functions
        function createShopProduct(string memory _name, uint32 _quantity) public onlyOwner {
            Product memory newProduct = Product(_name, _quantity);
            shop[msg.sender].push(newProduct);
            emit ProductAdded(msg.sender, _name, _quantity);
        }

        function deleteShopProduct(uint256 index) public onlyOwner {
            require(index < shop[msg.sender].length, "Index out of bounds");
            string memory productName = shop[msg.sender][index].name; // Get product name for event

            for (uint256 i = index; i < shop[msg.sender].length - 1; i++) {
                shop[msg.sender][i] = shop[msg.sender][i + 1]; // Shift products down
            }
            shop[msg.sender].pop(); // Remove the last element

            emit ProductDeleted(msg.sender, productName);
        }

        function updateProductQuantity(string memory _name, uint32 _newQuantity) public onlyOwner {
            for (uint256 i = 0; i < shop[msg.sender].length; i++) {
                if (compareStrings(shop[msg.sender][i].name, _name)) {
                    shop[msg.sender][i].quantity = _newQuantity; // Update the quantity
                    emit ProductUpdated(msg.sender, _name, _newQuantity); // Emit the event
                    return;
                }
            }
            revert("Product not found in the shop.");
        }

        // Cart functions
        function addToCart(string memory _productName, uint32 _quantity) public {
            bool productExists = false;
            for (uint256 i = 0; i < shop[owner].length; i++) {
                if (compareStrings(shop[owner][i].name, _productName)) {
                    require(shop[owner][i].quantity >= _quantity, "Not enough product in stock.");
                    productExists = true;
                    break;
                }
            }
            require(productExists, "Product does not exist in the shop.");

            carts[msg.sender].push(Product(_productName, _quantity));
        }

        function removeFromCart(uint256 index) public {
            require(index < carts[msg.sender].length, "Index out of bounds");
            for (uint256 i = index; i < carts[msg.sender].length - 1; i++) {
                carts[msg.sender][i] = carts[msg.sender][i + 1]; // Shift products down
            }
            carts[msg.sender].pop(); // Remove the last element
        }

        // Order functions
        function createOrder() public {
            Product[] memory _orderList = carts[msg.sender];
            require(_orderList.length > 0, "Cart is empty");

            for (uint32 i = 0; i < _orderList.length; i++) {
                bool productExists = false;
                for (uint256 j = 0; j < shop[owner].length; j++) {
                    if (compareStrings(shop[owner][j].name, _orderList[i].name)) {
                        require(shop[owner][j].quantity >= _orderList[i].quantity, "Not enough product in stock.");
                        productExists = true;
                        break;
                    }
                }
                require(productExists, "Product does not exist in the shop.");
            }

            Order storage order = orders[orderCount];
            order.id = totalOrderId;
            order.currentOwner = owner; 
            order.finalOwner = msg.sender;
            order.status = "Preparing Order";
            order.ownerHistory.push(owner);
            
            for (uint32 i = 0; i < _orderList.length; i++) {
                for (uint256 j = 0; j < shop[owner].length; j++) {
                    if (compareStrings(shop[owner][j].name, _orderList[i].name)) {
                        shop[owner][j].quantity -= _orderList[i].quantity; // Deduct product quantity
                        order.products.push(_orderList[i]); 
                        break;
                    }
                }
            }

            emit OrderAdded(orderCount, order.status, owner, _orderList);

            delete carts[msg.sender];
            emit CartCleared(msg.sender); 

            totalOrderId++;
            orderCount++;

            // Track active orders
            activeOrders[msg.sender].push(order.id);
        }   

        function transferOwnership(uint256 _id, address _newOwner) public {
            Order storage order = orders[_id]; 
            require(order.currentOwner == msg.sender, "Only the current owner can transfer ownership.");
            require(_newOwner != order.currentOwner, "New owner is the same as current owner.");

            order.currentOwner = _newOwner; 
            order.status = "In Transit"; 
            order.ownerHistory.push(_newOwner); 
            emit OwnershipTransferred(_id, msg.sender, _newOwner);

            if (_newOwner == order.finalOwner) {
                finishOrder(_id);
            }
        }

        function finishOrder(uint256 _id) internal {
            Order storage order = orders[_id];
            order.status = "Finished Order";
            
            completedOrders.push(order);
            
            delete orders[_id];

            // Remove order ID from activeOrders mapping
            uint256[] storage userOrders = activeOrders[order.finalOwner];
            for (uint256 i = 0; i < userOrders.length; i++) {
                if (userOrders[i] == _id) {
                    userOrders[i] = userOrders[userOrders.length - 1]; // Move last element to the removed spot
                    userOrders.pop(); // Remove last element
                    break;
                }
            }

            for (uint256 i = _id; i < orderCount - 1; i++) {
                orders[i] = orders[i + 1];
            }

            delete orders[orderCount - 1];

            orderCount--;

            emit OrderCompleted(_id);
        }

        // Helper function to compare strings
        function compareStrings(string memory a, string memory b) internal pure returns (bool) {
            return (keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)));
        }
    }
