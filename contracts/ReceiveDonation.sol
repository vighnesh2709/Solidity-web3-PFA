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
        uint rating;
        uint noRating;
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
    ) public onlyOwner returns (string memory) {
        Suppliers storage s = suppliers[SupplierName];
        s.supplierAdd = SupplierAdd;
        s.required = required;

        emit Status("Added Supplier"); 
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

    function DonorConfirmation(
            string memory supplierName, 
            uint rating
        ) external {
        // Validate rating is between 1 and 5
            require(rating >= 1 && rating <= 5, "Rating must be between 1 and 5");
        
        // Retrieve the supplier
            Suppliers storage supplier = suppliers[supplierName];
            require(supplier.supplierAdd != address(0), "Supplier does not exist");
        
        // Calculate new rating
        // New rating = (Current total rating + New rating) / (Number of ratings + 1)
            supplier.rating = (supplier.rating * supplier.noRating + rating) / (supplier.noRating + 1);
        
        // Increment number of ratings
            supplier.noRating += 1;
        
        // Emit an event to log the rating
            emit Status("Donor rating submitted successfully");
    }
    
    // New function to track the average score of a supplier
    function TrackScore(
        string memory supplierName
    ) external view returns (uint averageRating, uint numberOfRatings) {
        Suppliers storage supplier = suppliers[supplierName];
        
        // Return the current average rating and number of ratings
        return (supplier.rating, supplier.noRating);
    }
    
}