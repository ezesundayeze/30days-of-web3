// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "forge-std/Test.sol";
import "../src/voting.sol";

contract MerkleTreeElectionTest is Test {
    MerkleTreeElection election;

    // Sample data
    bytes32[] public identities;
    bytes32 public merkleRoot;

    function setUp() public {
        election = new MerkleTreeElection();

        identities = new bytes32[](4);
        identities[0] = keccak256(abi.encodePacked("123456789"));
        identities[1] = keccak256(abi.encodePacked("987654321"));
        identities[2] = keccak256(abi.encodePacked("111223344"));
        identities[3] = keccak256(abi.encodePacked("556677889"));

        merkleRoot = computeMerkleRoot(identities);
        election.setMerkleRoot(merkleRoot);

        console.log("Merkle Root set in contract:", uint256(merkleRoot));
    }

    function testVoting() public {
        bytes32[] memory leaves = identities;

        for (uint i = 0; i < leaves.length; i++) {
            console.log("Leaf", i, ":", uint256(leaves[i]));
        }

        bytes32 calculatedRoot = computeMerkleRoot(leaves);
        console.log("Calculated Merkle Root:", uint256(calculatedRoot));
        console.log("Contract Merkle Root:", uint256(merkleRoot));

        bytes32[] memory proof = generateMerkleProof(leaves, 0);

        console.log("Proof Length:", proof.length);
        for (uint i = 0; i < proof.length; i++) {
            console.log("Proof Element", i, ":", uint256(proof[i]));
        }

        console.log("Leaf being verified:", uint256(leaves[0]));

        // bool isValid = election.verifyMerkleProof(proof, leaves[0]);
        bool isValid = MerkleProof.verify(merkleProof, merkleRoot, leafHash);

        console.log("Is proof valid?", isValid);

        if (!isValid) {
            // Manually verify the proof
            bytes32 computedHash = leaves[0];
            for (uint i = 0; i < proof.length; i++) {
                bytes32 proofElement = proof[i];
                if (computedHash <= proofElement) {
                    computedHash = keccak256(
                        abi.encodePacked(computedHash, proofElement)
                    );
                } else {
                    computedHash = keccak256(
                        abi.encodePacked(proofElement, computedHash)
                    );
                }
                console.log("Step", i, "Computed Hash:", uint256(computedHash));
            }
            console.log("Final Computed Hash:", uint256(computedHash));
            console.log("Merkle Root:", uint256(merkleRoot));
        }

        election.vote(1, proof, leaves[0]);
        assertTrue(election.hasVoted(leaves[0]), "Voter 1 should have voted.");
        assertEq(
            election.candidateVotes(1),
            1,
            "Candidate 1 should have 1 vote."
        );
    }

    function testInvalidVoting() public {
        // Providing an invalid proof
        bytes32[] memory invalidProof = new bytes32[](1);
        invalidProof[0] = bytes32(0);

        // Expect the transaction to revert due to invalid proof
        vm.expectRevert(MerkleTreeElection.InvalidProof.selector);
        election.vote(1, invalidProof, identities[0]);
    }

    function computeMerkleRoot(
        bytes32[] memory leaves
    ) internal pure returns (bytes32) {
        require(leaves.length > 0, "No leaves provided");

        while (leaves.length > 1) {
            uint256 length = leaves.length;
            uint256 newLength = (length + 1) / 2;
            bytes32[] memory newLeaves = new bytes32[](newLength);

            for (uint256 i = 0; i < length; i += 2) {
                bytes32 left = leaves[i];
                bytes32 right = (i + 1 < length) ? leaves[i + 1] : left;
                newLeaves[i / 2] = keccak256(abi.encodePacked(left, right));
            }

            leaves = newLeaves;
        }

        return leaves[0];
    }

    // Generate the Merkle proof for a specific leaf.
    function generateMerkleProof(
        bytes32[] memory leaves,
        uint256 leafIndex
    ) public returns (bytes32[] memory) {
        require(leaves.length > 0, "No leaves provided");
        require(leafIndex < leaves.length, "Leaf index out of bounds");

        uint256 n = leaves.length;
        bytes32[] memory proof = new bytes32[](n - 1); // Proof size will be at most (n-1)
        uint256 proofIndex = 0;
        bytes32[] memory currentLevel = leaves;

        while (n > 1) {
            // Calculate the next level
            uint256 nextLevelSize = (n + 1) / 2;
            bytes32[] memory nextLevel = new bytes32[](nextLevelSize);

            for (uint256 i = 0; i < n; i += 2) {
                bytes32 left = currentLevel[i];
                bytes32 right = (i + 1 < n) ? currentLevel[i + 1] : left; // Handle odd number of nodes by duplicating the last one

                nextLevel[i / 2] = keccak256(abi.encodePacked(left, right));

                // Add the sibling to the proof if it involves the current leaf
                if (i == leafIndex || i + 1 == leafIndex) {
                    proof[proofIndex++] = (i == leafIndex) ? right : left;
                    leafIndex = i / 2;
                }
            }

            currentLevel = nextLevel;
            n = nextLevelSize;
        }

        // Set the root once the tree is built
        merkleRoot = currentLevel[0];

        // Resize the proof to match the actual number of proof elements
        bytes32[] memory finalProof = new bytes32[](proofIndex);
        for (uint256 i = 0; i < proofIndex; i++) {
            finalProof[i] = proof[i];
        }

        return finalProof;
    }
}
