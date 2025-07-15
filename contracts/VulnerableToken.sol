// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ICallback {
    function tokensReceived(uint256 amount) external;
}

contract VulnerableToken {
    string public name = "VulnToken";
    string public symbol = "VULN";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public pendingWithdrawals;

    address public owner;

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply;
        balanceOf[msg.sender] = _initialSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        return true;
    }

    function mint(uint256 _amount) public {
        totalSupply += _amount;
        balanceOf[msg.sender] += _amount;
    }

    function burn(uint256 _amount) public {
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
    }
    
    function deposit(uint _amount) public {
    balanceOf[msg.sender] -= _amount;
    pendingWithdrawals[msg.sender] += _amount;
    }

    function withdraw() public {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "Wallet has nothing to withdraw.");

        if(isContract(msg.sender)) {
            ICallback(msg.sender).tokensReceived(amount);
        }

        pendingWithdrawals[msg.sender] = 0;
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}