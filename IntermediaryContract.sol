// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IntermediaryContract {
    address public owner;
    struct Transaction {
        bytes32 maskedId;
        bytes32 unlockHash;
        uint256 value;
        uint256 index;
    }

    mapping(bytes32 => Transaction) private transactions;
    mapping(bytes32 => address) private receiverAddresses;
    uint256 public currentTransactionIndex = 0;
    uint256 public constant MAX_DEPOSIT = 2 * 1e18; // 2 MATIC
    uint256 public constant TRANSACTION_FEE = 0.005 * 1e18; // 0.005 MATIC
    bytes32[] private transactionIds; // Array to store transaction identifiers

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function depositFunds(bytes32 maskedId, bytes32 unlockHash) external payable {
        require(msg.value <= MAX_DEPOSIT, "Deposit exceeds maximum allowed");
        require(msg.value > TRANSACTION_FEE, "Must cover the transaction fee of 0.05 MATIC");

        uint256 depositAmount = msg.value - TRANSACTION_FEE;
        bytes32 transactionId = keccak256(abi.encodePacked(maskedId, unlockHash, currentTransactionIndex));

        transactions[transactionId] = Transaction(maskedId, unlockHash, depositAmount, currentTransactionIndex);
        transactionIds.push(transactionId);
        currentTransactionIndex++;

        // Transfer fee to intermediary (owner)
        payable(owner).transfer(TRANSACTION_FEE);
    }

    function unlockFunds(bytes32 transactionId, string memory secretString) external {
        Transaction memory trx = transactions[transactionId];
        require(trx.value > 0, "No funds to withdraw");
        require(keccak256(abi.encodePacked(secretString)) == trx.unlockHash, "Incorrect unlock string");

        address receiver = receiverAddresses[trx.maskedId];
        require(receiver != address(0), "Receiver not specified");
        
        transactions[transactionId].value = 0;
        (bool sent, ) = receiver.call{value: trx.value}("");
        require(sent, "Failed to send Ether");
    }

    function setReceiverAddress(bytes32 maskedId, address newReceiver) external onlyOwner {
        receiverAddresses[maskedId] = newReceiver;
    }

    function getTransactionDetails(bytes32 transactionId) public view returns (Transaction memory) {
        return transactions[transactionId];
    }

    function getAllTransactions(uint startIndex, uint endIndex) public view returns (Transaction[] memory) {
        require(endIndex <= transactionIds.length, "End index out of bounds");
        require(startIndex < endIndex, "Start index must be less than end index");

        uint256 range = endIndex - startIndex;
        Transaction[] memory transactionData = new Transaction[](range);

        for (uint256 i = 0; i < range; i++) {
            transactionData[i] = transactions[transactionIds[startIndex + i]];
        }

        return transactionData;
    }

    function makeHash(string memory toHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(toHash));
    }
}



