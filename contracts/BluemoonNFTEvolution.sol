// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BluemoonNFTEvolution is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIds;

    address payable public contractOwner;
    uint256 public maxSupply = 3333;
    uint256 public mintLimit;
    address[] public whitelist;

    uint256 public startTime;
    uint256 public endTime;

    event NFTMinted(address creator, uint indexed tokenId);
    event MetadataUpdated(uint256 tokenId, bool status);

    mapping(address => uint256) mintedNumPerWallet;
    mapping(uint256 => bool) updatedStatus;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        contractOwner = payable(msg.sender);
    }

    function setMintLimitPerWallet(uint256 _amount) public onlyOwner returns (uint256) {
        mintLimit = _amount;
        return mintLimit;
    }

    function addToWhitelist(address _member) external onlyOwner returns (uint256) {
        uint256 length = whitelist.length;
        bool flag;
        for (uint256 i = 0; i < length; i++) {
            if (whitelist[i] == _member) {
                flag = true;
            }
        }

        require(flag == false, "This memeber already exists in the whitelist!");
        whitelist.push(_member);

        return whitelist.length;
    }

    function removeFromWhitelist(address _member) external onlyOwner returns (uint256) {
        uint256 length = whitelist.length;
        uint256 index = length;
        for (uint256 i = 0; i < length; i++) {
            if (whitelist[i] == _member) {
                index = i;
            }
        }

        require(index != length, "This memeber doesn't exist in the whitelist!");

        whitelist[index] = whitelist[length - 1];
        whitelist.pop();

        /* delete whitelist[length - 1];
        assembly { mstore(whitelist.slot, sub(sload(whitelist.slot), 1)) } */

        return whitelist.length;
    }

    function setMintPeriod(uint256 _start, uint256 _end) external {
        startTime = _start;
        endTime = _end;
    }

    function mintNFT() public returns (uint256) {
        require(mintedNumPerWallet[msg.sender] < mintLimit, "Exceeded to mint limit");

        if (block.timestamp >= startTime && block.timestamp <= endTime) {
            uint256 length = whitelist.length;
            bool flag;
            for (uint256 i = 0; i < length; i++) {
                if (whitelist[i] == msg.sender) {
                    flag = true;
                }
            }

            require(flag == true, "You are not allowed to mint this NFT collection!");
        }
        
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        require(newItemId <= maxSupply, "The number of total mint is exceeded");

        _safeMint(msg.sender, newItemId);

        string memory tokenUri = string(abi.encodePacked("example.com/", newItemId.toString(), ".json"));

        _setTokenURI(newItemId, tokenUri);

        mintedNumPerWallet[msg.sender] ++;

        emit NFTMinted(msg.sender, newItemId);

        return newItemId;
    }

    function updateMetadata(uint256 _tokenId) public {
        require(updatedStatus[_tokenId] == false, "This NFT's metadata is already updated!");
        
        updatedStatus[_tokenId] = true;

        emit MetadataUpdated(_tokenId, true);
    }
}