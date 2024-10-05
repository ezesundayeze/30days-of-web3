// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CrowdFunding is ReentrancyGuard {
    IERC20 public usdtToken;

    uint256 public target;
    uint256 public totalAmountDonated;
    address public owner;
    mapping(address => uint256) public donations;

    error InvalidDonation();
    error TransferFailed();
    error FailedWithdrawal();
    error InvalidWithdrawal();

    event Donation(address indexed from, uint256 amount);
    event Withdrawal(address indexed from, uint256 amount);

    constructor(address usdtTokenContractAddress, uint256 _target) {
        usdtToken = IERC20(usdtTokenContractAddress);
        target = _target;
        owner = msg.sender;
    }

    function donate(uint256 amount) external nonReentrant {
        require(amount >= 0, InvalidDonation());

        require(
            usdtToken.transferFrom(msg.sender, address(this), amount),
            TransferFailed()
        );

        donations[msg.sender] += amount;
        totalAmountDonated += amount;

        emit Donation(msg.sender, amount);
    }

    function withdraw(address externalAddress) external nonReentrant {
        require(totalAmountDonated == target, InvalidWithdrawal());
        uint256 amountToWithdraw = totalAmountDonated;

        require(
            usdtToken.transfer(externalAddress, amountToWithdraw),
            FailedWithdrawal()
        );

        totalAmountDonated = 0;
        emit Withdrawal(msg.sender, totalAmountDonated);
    }
}
