// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20 <0.8.23;

// Import the Ownable2Step contract from the OpenZeppelin library.
import "@openzeppelin/contracts/access/Ownable2Step.sol";

abstract contract Authorizable is Ownable2Step {
    // Mapping to store authorized addresses.
    mapping(address => bool) private authorized;

    // Mapping to store client names for authorized addresses.
    mapping(address => mapping(bool => string)) private authorizedClients;

    // Modifier to restrict access to authorized addresses and the owner.
    modifier onlyAuthorized() {
        require(
            authorized[msg.sender] || owner() == msg.sender,
            "Not authorized"
        );
        _;
    }

    // Modifier to restrict access to authorized clients based on their client name.
    modifier onlyAuthorizedClient(string memory _clientName) {
        require(
            hasMatchingClientName(msg.sender, _clientName),
            "Not authorized client"
        );
        _;
    }

    // Function to check if a provided client name matches the stored client name.
    function hasMatchingClientName(
        address _clientAddress,
        string memory _clientName
    ) internal view returns (bool) {
        bytes memory storedNameBytes = bytes(
            authorizedClients[_clientAddress][true]
        );
        bytes memory providedNameBytes = bytes(_clientName);

        // Check if the lengths of the stored and provided names match.
        if (storedNameBytes.length != providedNameBytes.length) {
            return false;
        }

        // Compare each character in the stored and provided names.
        for (uint256 i = 0; i < storedNameBytes.length; i++) {
            if (storedNameBytes[i] != providedNameBytes[i]) {
                return false;
            }
        }

        return true;
    }

    // Function to check if an address is authorized.
    function isAuthorised(address _authAdd) public view returns (bool _isAuth) {
        _isAuth = (authorized[_authAdd] || owner() == _authAdd);
    }

    // Function to add an address to the list of authorized addresses, only callable by the owner.
    function addAuthorized(address _toAdd) public onlyOwner {
        require(_toAdd != address(0), "Invalid address");
        authorized[_toAdd] = true;
    }

    // Function to remove an address from the list of authorized addresses, only callable by the owner.
    function removeAuthorized(address _toRemove) public onlyOwner {
        require(_toRemove != msg.sender, "Cannot remove yourself");
        authorized[_toRemove] = false;
    }

    // Function to set the client name for an authorized address, only callable by the owner.
    function setAuthorizedClient(
        address _client,
        string memory _clientName
    ) public onlyAuthorized {
        authorizedClients[_client][true] = _clientName;
    }

    // Function to remove the client name for an authorized address, only callable by the owner.
    function removeAuthorizedClient(address _client) public onlyAuthorized {
        authorizedClients[_client][true] = "";
    }

    // Function to get the client name associated with an authorized address.
    function getAuthorizedClient(
        address _client
    ) public view returns (string memory _clientName) {
        _clientName = authorizedClients[_client][true];
    }

    // Function to check if an address has an associated client name.
    function isAuthorizedClient(
        address _client
    ) public view returns (bool _isAuth) {
        _isAuth = (bytes(authorizedClients[_client][true]).length > 0);
    }
}