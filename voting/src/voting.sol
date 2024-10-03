// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleTreeElection {
    address owner;

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
        bytes32 leafHash
    ) public {
        // Step 1: Check if the voter has already voted using the leaf hash.
        require(!hasVoted[leafHash], AlreadyVoted());

        // Step 2: Ensure the Merkle proof is valid before proceeding using OpenZeppelin's MerkleProof library.
        bool isValidProof = MerkleProof.verify(
            merkleProof,
            merkleRoot,
            leafHash
        );
        require(isValidProof, InvalidProof());

        // Step 3: Record the vote if the proof is valid.
        candidateVotes[candidateId]++;
        totalVotes++;

        // Mark the voter as having voted to prevent double voting.
        hasVoted[leafHash] = true;

        // Emit the Voted event to log the vote details.
        emit Voted(leafHash, candidateId);
    }
}
