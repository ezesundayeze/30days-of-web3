// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "forge-std/Test.sol";
import "../src/voting.sol";

/**
 * @title MerkleTreeElectionTest
 * @dev Test contract for the MerkleTreeElection smart contract
 */
contract MerkleTreeElectionTest is Test {
    MerkleTreeElection election;

    /**
     * @dev Setup function to deploy the MerkleTreeElection contract and set the Merkle root
     */
    function setUp() public {
        election = new MerkleTreeElection();

        // Set Merkle root in the election contract
        // This Merkle root is derived off-chain using the OpenZeppelin library
        // Refer to the off-chain folder for the JavaScript code used to generate this root
        election.setMerkleRoot(
            0xae5005d0ae3e10e51fa955c8f240b024fe07ed38c9825df70b84445e3adb446d
        );
    }

    /**
     * @dev Test function to verify voting with a valid Merkle proof
     */
    function testVotingWithValidProof() public {
        // Create a leaf node by hashing a sample passport ID
        // In a real scenario, users would enter their actual passport ID here
        bytes32 leaf = keccak256(abi.encodePacked("111223344"));

        // Generate a valid Merkle proof for the leaf -- you'll generate this proof off-chain together with the leaf using the Javascript library in the off-chain directory.
        bytes32[] memory proof = new bytes32[](2);

        proof[
            0
        ] = 0x2a359feeb8e488a1af2c03b908b3ed7990400555db73e1421181d97cac004d48;
        proof[
            1
        ] = 0x8b4ea9b2c71f1d36b1fb6541091d8457f887bd052f2350c1883370aea2661b1f;

        election.vote(1, proof, leaf);

        assertTrue(
            election.hasVoted(leaf),
            "Voter should have been marked as voted."
        );
        assertEq(
            election.candidateVotes(1),
            1,
            "Candidate 1 should have 1 vote."
        );
    }

    /**
     * @dev Test function to verify that voting with an invalid Merkle proof fails
     */
    function testInvalidVoting() public {
        // Generate an intentionally invalid proof
        bytes32[] memory invalidProof = new bytes32[](1);
        invalidProof[0] = bytes32(0);

        // Create a leaf node (same as in the valid voting test)
        bytes32 leaf = keccak256(abi.encodePacked("111223344"));

        // Expect the transaction to revert with an InvalidProof error
        vm.expectRevert(
            abi.encodeWithSelector(MerkleTreeElection.InvalidProof.selector)
        );
        election.vote(1, invalidProof, leaf);
    }
}
