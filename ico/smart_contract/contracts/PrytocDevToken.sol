// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IPrytocDevs.sol";

contract PrytocDevToken is ERC20, Ownable {
    // Price of one Token
    uint256 public constant tokenPrice = 0.001 ether;

    uint256 public constant tokensPerNft = 10 * 10**18;
    uint256 public constant maxTotalSupply = 10000 * 10**18;

    IPrytocDevs PrytocDevNFT;
    // Mapping to keep track of which NFT tokenIds have been claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _prytocDevsContract) ERC20("Prytoc Dev Token", "PD") {
        PrytocDevNFT = IPrytocDevs(_prytocDevsContract);
    }

    function mint(uint256 amount) public payable {
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Ether sent is wrong!");

        uint256 amountWithDecimals = amount * 10**18;
        require((totalSupply() + amountWithDecimals) <= maxTotalSupply, "Exceeds the max total supply available");

        _mint(msg.sender, amountWithDecimals);
    }

    function claim() public {
        address sender = msg.sender;
        uint256 balance = PrytocDevNFT.balanceOf(sender);
        require(balance > 0, "You dont own any Crypto Dev NFT's");
        uint256 amount = 0;
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = PrytocDevNFT.tokenOfOwnerByIndex(sender, i);
            if(!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        require(amount > 0, "You have already claimed all the tokens");
        _mint(msg.sender, amount * tokensPerNft);
    }

    function withdraw() public onlyOwner{
        uint256 amount = address(this).balance;
        require(amount > 0, "Nothing to withdraw; contract balance empty");

        address _owner = owner();
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "failed to send ether");
    }

    receive()  external payable {}
    fallback() external payable {}
}
