// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "OpenZeppelin/openzeppelin-contracts@3.4.0/contracts/token/ERC721/ERC721.sol";
import "smartcontractkit/chainlink-brownie-contracts@1.1.1/contracts/src/v0.6/VRFConsumerBase.sol";

contract AdvancedCollectible is ERC721, VRFConsumerBase {

    bytes32 internal keyHash;
    uint256 public fee;
    uint256 tokenCounter;
    
    enum Breed{PUG, SHIBA_INU, ST_BERNARD}

    mapping(bytes32 => address) public requestIdToSender;
    mapping(bytes32 => string) public requestIdToTokenURI;
    mapping(uint256 => Breed) public tokenIdToBreed;
    mapping(bytes32 => uint256) public requestIdToTokenURI;
    event requestCollectible(bytes32 indexed requestId);

    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyHash) public 
    VRFConsumerBase(_VRFCoordinator, _LinkToken)
    ERC721("Doggies", "DOG")
    {
        keyHash = _keyHash;
        fee = 0.1 * 10 ** 18; // 0.1 LINK 10^18
        tokenCounter = 0;
    }

    function createCollectible(string memory tokenURI) public returns (bytes32) 
    {
        bytes32 requestId = requestRandomness(keyHash, fee);
        requestIdToSender[requestId] = msg.sender;
        requestIdToTokenURI[requestId] = tokenURI;
        emit requestedCollectible(requestId);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal override {
        address dogOwner = requestIdToSender[requestId];  // unpack id
        string memory tokenURI = requestIdToTokenURI[requestId];
        uint256 newItemId = tokenCounter;
        _safeMint(dogOwner, newItemId);
        _setTokenURI(newItemId, tokenURI);
        Breed breed = Breed(randomNumber % 3);
        tokenIdToBreed[newItemId] = breed;
        requestIdToTokenId[requestId] = newItemId;
        tokenCounter ++;
    }
}