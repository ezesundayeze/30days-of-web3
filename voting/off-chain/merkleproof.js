const { keccak256 } = require('js-sha3');

function computeMerkleRoot(identityNumbers) {
    if (identityNumbers.length === 0) {
        throw new Error("No identity numbers provided.");
    }

    // Step 1: Hash the identity numbers
    let hashedLeaves = identityNumbers.map(identity => keccak256(identity));

    // Step 2: Construct the Merkle tree
    while (hashedLeaves.length > 1) {
        const newLevel = [];

        for (let i = 0; i < hashedLeaves.length; i += 2) {
            // If there's an odd leaf, duplicate it to hash with itself
            const left = hashedLeaves[i];
            const right = i + 1 < hashedLeaves.length ? hashedLeaves[i + 1] : left;
            // Concatenate and hash the pair
            const combinedHash = keccak256(left + right);
            newLevel.push(combinedHash);
        }

        hashedLeaves = newLevel; // Move up to the new level
    }

    // The only element left is the Merkle root
    return hashedLeaves[0];
}

// Example usage
const identityNumbers = [
    "123456789", // Replace with actual voter identity numbers
    "987654321",
    "111223344",
    "556677889"
];

const merkleRoot = computeMerkleRoot(identityNumbers);
console.log("Merkle Root:", merkleRoot);
