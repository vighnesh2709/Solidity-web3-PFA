// SPDX-License-Identifier: MIT OR GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

import "./ReceiveDonation.sol";

contract Adoption {
    constructor(address _ReceiveDonationAddress) {
        owner = msg.sender;
        ReceiveDonationAddress = _ReceiveDonationAddress;
        transC = ReceiveDonation(payable(_ReceiveDonationAddress));
    }

    event Status(string message);
    event Debug(string message, uint256 value);

    address public owner;
    address public ReceiveDonationAddress;
    ReceiveDonation public transC;

    struct Details {
        string name;
        bool adopted;
        address adoptersAddress;
    }
    struct Animal {
        string name;
        string species;
        address userAddress;
        Details additionalDetails;
    }

    mapping(address => Animal) animals;

    function checkValue() public view returns (uint) {
        // Call the checkValue function from the ReceiveDonation contract
        return transC.checkValue(address(0));
    }

    function incentiveTransfer(address sendersAddress) private returns (bool) {
        uint currentAmount = transC.checkValue(address(0));
        emit Debug("Amount is:", currentAmount);
        require(currentAmount > 0, "No incentive funds available");
        uint amountToSend = (currentAmount * 10) / 100;
        bool status = transC.sendEthAdoption(sendersAddress, amountToSend);
        require(status, "Transaction did not happen");
        emit Status("Transaction completed");
        return status;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

    function addAnimal(
        string memory _name,
        string memory _species,
        address _userAddress
    ) public onlyOwner returns (string) {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_species).length > 0, "Species cannot be empty");
        require(_userAddress != address(0), "Invalid address");
        require(
            animals[_userAddress].userAddress == address(0),
            "Animal already added for this address"
        );
        animals[_userAddress] = Animal({
            name: _name,
            species: _species,
            userAddress: _userAddress,
            additionalDetails: Details("", false, address(0))
        });
        return "Details Added";
    }

    function getAnimal(
        address _userAddress
    )
        public
        view
        returns (
            string memory,
            string memory,
            address,
            string memory,
            bool,
            address
        )
    {
        require(
            animals[_userAddress].userAddress != address(0),
            "Animal does not exist"
        );
        Animal memory animal = animals[_userAddress];
        return (
            animal.name,
            animal.species,
            animal.userAddress,
            animal.additionalDetails.name,
            animal.additionalDetails.adopted,
            animal.additionalDetails.adoptersAddress
        );
    }

    function adopt(
        string memory _adopterName,
        address _adopterAddress,
        address _animalAddress
    )
        public
        onlyOwner
        returns (
            bool,
            string memory animalName,
            string memory species,
            address animalUserAddress,
            string memory adopterName,
            bool adoptedStatus,
            address adoptersAddress
        )
    {
        require(bytes(_adopterName).length > 0, "Adopter name cannot be empty");
        require(_adopterAddress != address(0), "Invalid adopter address");
        require(_animalAddress != address(0), "Invalid animal address");

        require(
            animals[_animalAddress].userAddress != address(0),
            "Animal does not exist"
        );

        require(
            animals[_animalAddress].additionalDetails.adopted == false,
            "Animal already adopted"
        );

        animals[_animalAddress].additionalDetails = Details(
            _adopterName,
            true,
            _adopterAddress
        );

        bool ans = incentiveTransfer(_adopterAddress);
        require(ans, "Transaction did not happen");
        emit Status("Transaction completed. NOT DUPLICATE");

        Animal memory animal = animals[_animalAddress];

        return (
            ans,
            animal.name,
            animal.species,
            animal.userAddress,
            animal.additionalDetails.name,
            animal.additionalDetails.adopted,
            animal.additionalDetails.adoptersAddress
        );
    }
}
