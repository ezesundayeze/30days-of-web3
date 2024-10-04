// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleTreeElection {
    address public owner;

    error Unauthorized();
    error AlreadyVoted();
    error InvalidProof();

    mapping(bytes32 => bool) public hasVoted;
    mapping(uint256 => uint256) public candidateVotes;

    bytes32 public merkleRoot;
    uint256 public totalVotes;

    event Voted(bytes32 indexed identityHash, uint256 indexed candidateId);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, Unauthorized());
        _;
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function vote(
        uint256 candidateId,
        bytes32[] memory merkleProof,
        bytes32 leafHash // Identity, e.g international passport
    ) public {
        require(!(hasVoted[leafHash]), AlreadyVoted());
        require(
            MerkleProof.verify(merkleProof, merkleRoot, leafHash),
            InvalidProof()
        );

        candidateVotes[candidateId]++;
        totalVotes++;

        hasVoted[leafHash] = true;

        emit Voted(leafHash, candidateId);
    }

    function getVotes(uint256 candidateId) public view returns (uint256) {
        return candidateVotes[candidateId];
    }
}
