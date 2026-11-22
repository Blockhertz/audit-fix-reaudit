# @version ^0.3.0

balances: HashMap[address, uint256]

@external
@payable
def deposit():
    self.balances[msg.sender] += msg.value

@external
def withdraw(amount: uint256):
    assert self.balances[msg.sender] >= amount
    self.balances[msg.sender] -= amount  # state updated BEFORE send
    send(msg.sender, amount)
