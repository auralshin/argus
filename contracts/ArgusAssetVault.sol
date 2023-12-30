// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20 <0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interfaces/IArgusRWA.sol";
import "./math/BancorFormula.sol";


/// @title ArgusAssetVault
/// @author Auralshin
/// @notice A contract for creating and managing Argus markets
/* implement various interface support for ArgusAssetVault 
    - Ownable: contract owner can withdraw Ether
    - ReentrancyGuard: prevent reentrancy attacks
    - BancorFormula: calculate purchase return for Bancor-like bonding curve

    Pending:
    - ERC721: implement ERC721 interface for external locking to ArgusAssetVault
    - ERC1155: implement ERC1155 interface for external locking to ArgusAssetVault
    - ERC20: implement ERC20 interface for external locking to ArgusAssetVault
    - IArgusRWA: Change it to custom non fungible token interface for security token
    - implement buy and sell functions, discuss auction mechanism @mundhrakeshav
    - Offchain order book mechanism (still in discussion) @mundhrakeshav

*/


contract ArgusAssetVault is Ownable, ReentrancyGuard, BancorFormula {

    mapping(address => uint256) public balances;
    IArgusRWA public ArgusRWA;
    IERC20 public tradingToken;

    event MarketCreated(address indexed creator, uint256 amountMinted);
    event Deposited(address indexed depositor, uint256 amount);
    event Withdrawn(address indexed recipient, uint256 amount);

    constructor(address initialOwner, address _assetAddress, address _tradingToken)
        Ownable(initialOwner)
    {
        ArgusRWA = IArgusRWA(_assetAddress);
        tradingToken = IERC20(_tradingToken);
    }

    function createMarket(
        uint256 reserveRatio,
        uint256 initialAmount,
        string memory uri
    ) public payable nonReentrant {
        require(initialAmount > 0, "Initial amount must be greater than 0");
        require(reserveRatio > 0 && reserveRatio <= 1000000, "Invalid reserve ratio");
        require(msg.value > 0, "Must send ether to create market");

        ArgusRWA.safeMint(msg.sender, uri);
        uint256 amountMinted = calculatePurchaseReturn(
            initialAmount,
            address(this).balance,
            uint32(reserveRatio),
            msg.value
        );
        require(amountMinted > 0, "Must mint at least 1 token");
        balances[msg.sender] = balances[msg.sender] + amountMinted;
        tradingToken.transfer(msg.sender, amountMinted);

        emit MarketCreated(msg.sender, amountMinted);
    }

    function deposit() public payable {
        require(msg.value > 0, "Cannot deposit 0 Ether");
        balances[msg.sender] = balances[msg.sender] + msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(owner()).transfer(amount);
        emit Withdrawn(owner(), amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
