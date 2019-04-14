pragma solidity ^0.5.0;

import "./Ownable.sol";

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }

}

interface BondingCurve {

    event Transfer(address indexed from, address indexed to, uint256 value);

    function mint(uint xdai) external;

    function getPrice() external view returns (uint price);

    function burn(uint amount) external;
}

contract BasicBondingCurve is BondingCurve, Ownable {

    using SafeMath for uint;

    uint _totalSupply;
    uint _xdai;

    mapping(address => uint) balances;

    constructor() public {
        
    }

    function () external payable {
        revert();
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function mint(address to, uint256 xdai) external onlyOwner returns (bool) {
        require(to != address(0), "Cannot mint to address(0).");
        // Determine number of tokens based on price and xdai
        uint price = _totalSupply.add(1);
        uint value = xdai.div(price);
        require(value != 0, "Value not enough to buy a single token.");
        // Add to balances and totalSupply
        balances[to] = balances[to].add(value);
        _totalSupply = _totalSupply.add(value);
        _xdai = _xdai.add(xdai);

        emit Transfer(address(0), to, value);
        return true;
    }

    function getPrice() external view returns (uint price) {
        return _totalSupply.add(1);
    }

    function burn(uint amount) external {
        require(amount <= _totalSupply, "Amount exceeds total supply.");
        require(balances[msg.sender] >= amount, "Amount exceeds user balance");

        // Determine xdai to pay out
        uint price = _totalSupply;
        uint value = amount.mul(price);

        // Subtract tokens from balances and totalSupply
        balances[msg.sender] = balances[msg.sender].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        _xdai = _xdai.sub(value);

        // TODO: Transfer 5% of xdai to Commons
        // TODO: Transfer 95% of xdai to receiver
        emit Transfer(msg.sender, address(0), amount);
    }
}