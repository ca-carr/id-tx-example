// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IdentityUnlockContract {
    // State variable to store the identity hash
    string private id_mask; // in practice this would not be included in the smart contract
    string private unlock_string; // in practice this would not be included in the smart contract
    bytes32 public unlock_chal;
    bytes32 public maskedID;
    string private id; // in practice this would not be included in the smart contract
    address public recadd = address(0); // Initialize to the zero address
    address public owner; // Owner's address, in this case the owener is the intermediary 

    event ReceivingAddressChanged(address newReceivingAddress);
    event ReceivingAddressChangeFailed(string reason);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    // Main constructor to set id, mask, unlock and the address of the intermediary
    constructor(string memory _id, string memory _id_mask, string memory _unlock, address _interAddress) payable {
        id = _id;
        id_mask = _id_mask;
        unlock_string = _unlock;
        unlock_chal = keccak256(abi.encode(unlock_string));
        maskedID = keccak256(abi.encode(_id, _id_mask));
        //owner = msg.sender;
        owner = _interAddress;
    }

    // Function to establish the receiving address, only if the caller is the intremediary owner
    function changeReceivingAddress(address _newAddress, string memory _id, string memory _id_mask) public onlyOwner {
        if (verifyID( _id, _id_mask )) 
        {
            recadd = _newAddress; // if true, we change the address to the one given
            emit ReceivingAddressChanged(_newAddress); // Emitting event with the new address
        } 
        else 
        {
            emit ReceivingAddressChangeFailed("ID verification failed"); // Emitting event indicating failure to change
        }
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
    function checkUnlock(string memory _unlock) public view returns (bool) {
        if (unlock_chal == keccak256(abi.encode( _unlock))) 
            { return true; }
        else 
            { return false; }
    }

        function payout(string memory _unlock) public {
        // Check that recadd is not the zero address
        require(recadd != address(0), "Receiving address not set");

        // Check that the unlock condition is true.
        require(checkUnlock(_unlock), "Unlock condition not met");

        // Send all funds in the contract to the receiving address.
        (bool sent, ) = recadd.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }


}
