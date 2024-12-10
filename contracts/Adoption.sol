// SPDX-License-Identifier: MIT OR GPL-3.0


pragma solidity >=0.4.22 <0.9.0;

contract Adoption {
    
    struct Details {
        string name;
        string adopted;
        address adoptersAddress;
    }
    struct Animal {
        string name;
        string species;
        address userAddress;
        Details additionalDetails;
    }


    mapping(address => Animal) public animals;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address newOwner) public onlyOwner{
        require(newOwner!=address(0));
        owner=newOwner;
    }

    function addAnimal(
        string memory _name,
        string memory _species,
        address _userAddress
    ) public onlyOwner {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_species).length > 0, "Species cannot be empty");
        require(_userAddress != address(0), "Invalid address");
        require(animals[_userAddress].userAddress == address(0), "Animal already added for this address");

        animals[_userAddress] = Animal({
            name: _name,
            species: _species,
            userAddress: _userAddress,
            additionalDetails: Details("", "No", address(0))
        });
    }

    function getAnimal(address _userAddress) public view returns (string memory, string memory, address,string memory,string memory,address) {
        require(animals[_userAddress].userAddress != address(0), "Animal does not exist");
        Animal memory animal = animals[_userAddress];
        return (animal.name, animal.species, animal.userAddress,animal.additionalDetails.name,animal.additionalDetails.adopted,animal.additionalDetails.adoptersAddress);
    }

    // this function is the adoption function that upon adoption, u get some moeny which will come from the main contract and then we good
    // who is adopting
    // who is getting adopted
    // address of who is adopting 
    // species of who is getting adopted
    // address of who is getting adopted
    function adopt(
        string memory _adopterName,
        address _adopterAddress,
        address _animalAddress
    ) public onlyOwner returns (
        string memory animalName,
        string memory species,
        address animalUserAddress,
        string memory adopterName,
        string memory adoptedStatus,
        address adoptersAddress
    ) {
        // Validation checks
        require(bytes(_adopterName).length > 0, "Adopter name cannot be empty");
        require(_adopterAddress != address(0), "Invalid adopter address");
        require(_animalAddress != address(0), "Invalid animal address");

        // Ensure the animal exists
        require(animals[_animalAddress].userAddress != address(0), "Animal does not exist");

        // Prevent duplicate adoptions
        require(bytes(animals[_animalAddress].additionalDetails.adopted).length == 0, "Animal already adopted");

    
        // Update adoption details
        animals[_animalAddress].additionalDetails = Details(_adopterName, "Yes", _adopterAddress);

        // Fetch updated animal details
        Animal memory animal = animals[_animalAddress];



        // Return updated details
        return (
            animal.name,
            animal.species,
            animal.userAddress,
            animal.additionalDetails.name,
            animal.additionalDetails.adopted,
            animal.additionalDetails.adoptersAddress
        );
    }
}
