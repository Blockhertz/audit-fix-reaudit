// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Round 1 — Original Vulnerable Contract
// Audit Score: 95/100 — Critical
// Finding: Reentrancy vulnerability in withdraw()

contract VulnerableToken {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // VULNERABLE: state update happens AFTER external call
    // attacker can re-enter before balance is set to zero
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        balances[msg.sender] -= amount; // too late — reentrancy possible
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}