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

    // Event to emit when the receiving address is changed
    event ReceivingAddressChanged(address newReceivingAddress);
    // Event to emit when an attempt to change the receiving address fails
    event ReceivingAddressChangeFailed(string reason);

    // Modifier to restrict function execution to the contract owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    //function lockEther() external payable {
    //    emit EtherLocked(msg.sender, msg.value);
    //}

    // Constructor to set the initial identity hash and the owner
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


        function z_pay(string memory _unlock) public {
        // Check that recadd is not the zero address.
        require(recadd != address(0), "Receiving address is not set.");

        // Check that the unlock condition is true.
        require(checkUnlock(_unlock), "Unlock condition is not satisfied.");

        // Send all the Ether in the contract to the receiving address.
        (bool sent, ) = recadd.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }



}
