// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Escrow is ReentrancyGuard {
    IERC20 public usdtToken;
    error TransferFailed();
    error InvalidAmount();
    error PriceMustBeGreaterThanZero();
    error TheProductMustBeDeliveredFirst();
    error Unauthorized();
    error FundsAlreadyReleased();
    error ProductDoesNotExists();

    struct Product {
        uint256 id;
        bytes name;
        uint256 price;
        address seller;
        bool isDelivered;
        bool isFundsReleased;
    }

    struct Transaction {
        address buyer;
        uint256 productId;
        uint256 amount;
        uint256 timestamp;
    }

    uint256 public productCount;
    uint256 public transactionCount;

    mapping(uint256 => Product) public products;
    mapping(uint256 => Transaction) public transactions;

    event Buy(address indexed buyer, Transaction indexed transaction);
    event Sell(address indexed seller, Product indexed product);
    event Release(address indexed seller, Product indexed product);
    event ProductDelivered(address indexed seller, Product indexed product);

    constructor(address usdtTokenContractAddress) {
        usdtToken = IERC20(usdtTokenContractAddress);
    }

    function sell(uint256 _price, bytes memory _name) external nonReentrant {
        productCount++;

        require(_price > 0, PriceMustBeGreaterThanZero());

        products[productCount] = Product({
            id: productCount,
            seller: msg.sender,
            name: _name,
            price: _price,
            isDelivered: false,
            isFundsReleased: false
        });

        emit Sell(msg.sender, products[productCount]);
    }

    function buy(uint256 _productId) external nonReentrant {
        transactionCount++;
        Product storage product = products[_productId];

        require(product.id > 0, ProductDoesNotExists());

        require(
            usdtToken.transferFrom(msg.sender, address(this), product.price),
            TransferFailed()
        );

        transactions[transactionCount] = Transaction({
            buyer: msg.sender,
            productId: _productId,
            amount: product.price,
            timestamp: block.timestamp
        });

        emit Buy(msg.sender, transactions[transactionCount]);
    }

    function deliver(uint256 _productId) external {
        Product storage product = products[_productId];
        require(msg.sender == product.seller, Unauthorized());

        product.isDelivered = true;
        emit ProductDelivered(msg.sender, product);
    }

    function release(
        address _sellerExternalAddress,
        uint256 _productId
    ) external nonReentrant {
        Product storage product = products[_productId];
        Transaction storage transaction = transactions[_productId];
        require(product.id > 0, ProductDoesNotExists());
        require(transaction.buyer == msg.sender, Unauthorized());

        require(product.isDelivered == true, TheProductMustBeDeliveredFirst());
        require(!product.isFundsReleased, FundsAlreadyReleased());

        product.isFundsReleased = true;

        require(
            usdtToken.transfer(_sellerExternalAddress, product.price),
            TransferFailed()
        );

        emit Release(product.seller, product);
    }
}
