const { SimpleMerkleTree } = require('@openzeppelin/merkle-tree');
const { solidityPackedKeccak256 } = require('ethers');

function merkleTree(identities = [
    "123456789",
    "987654321",
    "111223344",
    "556677889"
], identity = "123456789") {
    // Array of leaf nodes (in your case, the identities or data). In a real situation, you'll get this data from an authorized identity verification entity.
    // Leaves represent identities, posibly internation passport numbers, a leave is the individual passport
    let leaves = identities.map(identity =>
        solidityPackedKeccak256(['string'], [identity])
    );

    // Create Merkle tree
    const tree = SimpleMerkleTree.of(leaves);

    // Get Merkle root
    const root = tree.root;

    const leaf = solidityPackedKeccak256(['string'], [identity]);
    const proof = tree.getProof(leaf);

    return { proof, root }
}

console.log(merkleTree())

