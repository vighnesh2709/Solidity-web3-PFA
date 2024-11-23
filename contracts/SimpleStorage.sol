// SPDX-License-Identifier: MIT OR GPL-3.0


pragma solidity >=0.4.22 <0.9.0;

// pragma solidity ^0.8.0;

contract ReceiveDonation {
   struct Suppliers {
        address payable supplierAdd;
        uint required;
        uint received; 
   }
   mapping(string => Suppliers) suppliers;

   constructor() payable {}

   receive() external payable { }
   fallback() external payable { }
   
   function checkValue(address _current) public view returns(uint) {
        return _current.balance;
   }

   function addSupplier(address payable SupplierAdd, uint required, string memory SupplierName) public {
        Suppliers storage s = suppliers[SupplierName];
        s.supplierAdd = SupplierAdd;
        s.required = required;
   }

   function checkStatus(string memory to) public view returns(address,uint,uint,uint){
        return (suppliers[to].supplierAdd,suppliers[to].required,suppliers[to].received,suppliers[to].supplierAdd.balance);
   }
   
   function sendEth(string memory to, uint amount) external payable {
        require(address(this).balance >= amount, "This contract does not have that much amount to pay");
        require(suppliers[to].supplierAdd != address(0), "Supplier does not exist");
        require(suppliers[to].required>0,"Reached Monthly requirements,dont need any more");
        
        address payable supplier = suppliers[to].supplierAdd;
        uint newAmount = 0;

        if (suppliers[to].required >= amount) {
            suppliers[to].received += amount;
            suppliers[to].required -= amount;
            newAmount = amount;
        } else {
            newAmount = suppliers[to].required;
            suppliers[to].received += newAmount;
            suppliers[to].required = 0;
        }

        (bool success, ) = supplier.call{value: newAmount}("");
        require(success, "Transaction did not happen");
    }
}