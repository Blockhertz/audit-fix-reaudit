// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Round 3 — Final Safe Version
// Expected Score: Low Risk
// Fixes applied:
// 1. ReentrancyGuard added to withdraw()
// 2. onlyOwner access control added to drainFunds()
// 3. Events added for deposit, withdrawal and drain
// 4. Zero-amount check added to withdraw()
// 5. constructor sets owner via Ownable

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract FixedToken_v2 is Ownable, ReentrancyGuard {
    mapping(address => uint256) public balances;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Drained(address indexed recipient, uint256 amount);

    constructor() Ownable(msg.sender) {}

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    // nonReentrant guard + state before call + zero check + event
    function withdraw(uint256 amount) public nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    // onlyOwner access control + safe call pattern + event
    function drainFunds(address payable recipient) public onlyOwner {
        uint256 amount = address(this).balance;
        (bool ok, ) = recipient.call{value: amount}("");
        require(ok, "Transfer failed");
        emit Drained(recipient, amount);
    }
}