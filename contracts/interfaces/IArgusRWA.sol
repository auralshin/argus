// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20 <0.8.23;

interface IArgusRWA {
    // Event declarations (if any)

    // Function declarations
    function pause() external;
    function unpause() external;
    function safeMint(address to, string calldata uri) external;
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
