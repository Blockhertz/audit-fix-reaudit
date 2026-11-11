// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Round 2 — First Fix Attempt
// Audit Score: 95/100 — Critical
// Reentrancy fixed — but second-order vulnerability introduced:
// unprotected drainFunds() allows anyone to drain all contract funds

contract FixedToken_v1 {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // Reentrancy fixed: state updated BEFORE external call
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        balances[msg.sender] -= amount; // fixed
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    // SECOND-ORDER VULNERABILITY: no access control
    // any address can call this and drain all funds
    function drainFunds(address payable recipient) public {
        recipient.transfer(address(this).balance);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}