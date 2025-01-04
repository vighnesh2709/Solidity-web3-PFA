// SPDX-License-Identifier: MIT OR GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

contract ReceiveDonation {
    constructor() payable {
        owner = msg.sender;
    }

    receive() external payable {}
    fallback() external payable {}

    event Status(string message);
    event Debug(string message, uint256 value);

    address owner;

    struct Suppliers {
        address payable supplierAdd;
        uint required;
        uint received;
    }

    mapping(string => Suppliers) suppliers;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    function checkValue(address _current) public view returns (uint) {
        if (_current == address(0)) {
            return address(this).balance;
        } else {
            return _current.balance;
        }
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit Status("Invalid address");
        owner = newOwner;
    }

    function addSupplier(
        address payable SupplierAdd,
        uint required,
        string memory SupplierName
    ) public onlyOwner returns( string memory) {
        Suppliers storage s = suppliers[SupplierName];
        s.supplierAdd = SupplierAdd;
        s.required = required;
        return "Added Supplier";
    }

    function checkStatus(
        string memory to
    ) public view returns (address, uint, uint, uint) {
        return (
            suppliers[to].supplierAdd,
            suppliers[to].required,
            suppliers[to].received,
            suppliers[to].supplierAdd.balance
        );
    }

    function sendEthAdoption(
        address to,
        uint amount
    ) external payable returns (bool) {
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transaction did not take place");
        emit Status("Transaction Completed");
        return (true);
    }

    function sendEth(
        string memory to,
        uint amount
    ) external payable returns (string memory) {
        require(
            address(this).balance >= amount,
            "This contract does not have that much amount to pay"
        );
        emit Status("Checked contract balance, sufficient funds available.");

        require(
            suppliers[to].supplierAdd != address(0),
            "Supplier does not exist"
        );
        emit Status("Verified supplier existence.");

        if (suppliers[to].required < 0) {
            emit Status(
                "Reached Monthly requirements, amount stored in contract will be used when needed next."
            );
            return
                "Reached Monthly requirements, amount stored in contract will be used when needed next";
        }

        address payable supplier = suppliers[to].supplierAdd;
        uint newAmount = 0;

        if (suppliers[to].required >= amount) {
            suppliers[to].received += amount;
            suppliers[to].required -= amount;
            newAmount = amount;
            emit Status(
                "Transferred the requested amount within supplier's required limit."
            );
        } else {
            newAmount = suppliers[to].required;
            suppliers[to].received += newAmount;
            suppliers[to].required = 0;
            emit Status(
                "Transferred only the remaining required amount for the supplier."
            );
        }

        emit Debug("Contract balance before transfer", address(this).balance);
        emit Debug("Amount requested to transfer", amount);

        (bool success, ) = supplier.call{value: newAmount}("");
        require(success, "Transaction did not happen");

        emit Status("Funds transferred successfully.");
        return "Funds transferred successfully";
    }
}
