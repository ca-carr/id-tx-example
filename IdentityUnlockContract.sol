// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IdentityUnlockContract {
    // State variable to store the identity hash
    bytes32 private identityHash;
    string private id_mask;
    bytes32 private unlock;
    bytes32 private  maskedID;
    string private id;

    // Address of the legitimate user
    address private owner;

    // Event to emit when the identity hash is changed
    event IdentityChanged(bytes32 newIdentityHash);
    event EtherLocked(address sender, uint256 amount);

    // Modifier to restrict function execution to the contract owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    function lockEther() external payable {
        emit EtherLocked(msg.sender, msg.value);
    }

    // Constructor to set the initial identity hash and the owner
    constructor(bytes32 _identityHash, string memory _id, string memory _id_mask, bytes32 _unlock) {
        id = _id;
        id_mask = _id_mask;
        unlock = _unlock;
        identityHash = _identityHash;
        maskedID = keccak256(abi.encode(_id, _id_mask));
        owner = msg.sender;
    }

    // Function to change the identity hash, only if the caller is the owner
    function changeIdentityHash(bytes32 _newIdentityHash) public onlyOwner {
        identityHash = _newIdentityHash;
        emit IdentityChanged(_newIdentityHash);
    }

    // Function to verify if a provided hash matches the stored identity hash
    function verifyIdentity(bytes32 _hashToVerify) public view returns (bool) {
        return identityHash == _hashToVerify;
    }

    // Unlocking script that requires the correct hash to be provided before performing actions
    function unlockIdentity(bytes32 _providedHash, bytes32 _newIdentityHash) public onlyOwner {
        require(verifyIdentity(_providedHash), "Provided hash does not match the stored identity hash.");
        changeIdentityHash(_newIdentityHash);
    }

    function verifyID(string memory _id, string memory _id_mask) public view returns (bool) {
        bytes32 _maskedID = keccak256(abi.encode(_id, _id_mask));
        if (_maskedID == maskedID) 
            {  
                return true;
            } 
        else 
            {
                return false;
            }
    }

    // Function to retrieve the current identity hash (could be restricted as needed)
    function getIdentityHash() public view returns (bytes32) {
        return maskedID;
    }

    // Function to retrieve the current identity hash (could be restricted as needed)
    function getID() public view onlyOwner returns (string memory) {
        return id;
    }

    function robK() public view onlyOwner returns (bytes32) {
        return keccak256(abi.encodePacked(identityHash));
    }
}
