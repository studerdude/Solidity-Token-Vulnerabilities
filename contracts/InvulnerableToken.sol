// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ICallback {
    function tokensReceived(uint256 amount) external;
}

contract InvulnerableToken {
    string public name = "InvulnToken";
    string public symbol = "IVULN";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public pendingWithdrawals;
    

    address public owner;
    bool private reentrancyLocked;

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply;
        balanceOf[msg.sender] = _initialSupply;
    }

    modifier noReentrancy() {
        require(!reentrancyLocked, "Reentrancy detected");
        reentrancyLocked = true;
        _;
        reentrancyLocked = false;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Wallet does not have sufficient funds for this transfer.");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        return true;
    }

    function mint(uint256 _amount) public {
        require(msg.sender == owner, "Only the contract owner may mint tokens");
        totalSupply += _amount;
        balanceOf[msg.sender] += _amount;
    }

    function burn(uint256 _amount) public {
        require(balanceOf[msg.sender] >= _amount, "Wallet does not have sufficient funds to burn this amount.");
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
    }
    
    function deposit(uint _amount) public {
    require(balanceOf[msg.sender] >= _amount, "Wallet does not have sufficient funds for this deposit.");
    balanceOf[msg.sender] -= _amount;
    pendingWithdrawals[msg.sender] += _amount;
    }

    function withdraw() public noReentrancy {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "Wallet has nothing to withdraw.");

        pendingWithdrawals[msg.sender] = 0;
        balanceOf[msg.sender] += amount;

        if(isContract(msg.sender)) {
            ICallback(msg.sender).tokensReceived(amount);
        }
    }
    
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}