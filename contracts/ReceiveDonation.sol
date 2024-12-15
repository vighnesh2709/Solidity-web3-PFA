// SPDX-License-Identifier: MIT OR GPL-3.0


pragma solidity >=0.4.22 <0.9.0;

contract ReceiveDonation {
   
   address owner;
   struct Suppliers {
        address payable supplierAdd;    
        uint required;
        uint received; 
   }
   mapping(string => Suppliers) suppliers;

   constructor() payable {
    owner=msg.sender;
   }

   receive() external payable { }
   fallback() external payable { }
   
   function checkValue(address _current) public view returns(uint) {
        if (_current==address(0)){
          return address(this).balance;
        }else{
          return _current.balance;
        }
        
   }

   modifier onlyOwner(){
    require(msg.sender==owner,"Not Owner");
    _; 
   }

   function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Invalid address");
    owner = newOwner;
   }


   function addSupplier(address payable SupplierAdd, uint required, string memory SupplierName) public onlyOwner {
        Suppliers storage s = suppliers[SupplierName];
        s.supplierAdd = SupplierAdd;
        s.required = required;
   }

   function checkStatus(string memory to) public view returns(address,uint,uint,uint){
        return (suppliers[to].supplierAdd,suppliers[to].required,suppliers[to].received,suppliers[to].supplierAdd.balance);
   }

   // EOA do not have a bytecode where as contracts have a bytecode. So this function is checking if the given address has some bytecode, if yes its a contract. 
   function isContract(address addr) internal view returns (bool) {
    uint32 size;
    assembly {
        size := extcodesize(addr)
    }
    return (size > 0);
}

   function sendEthAdoption(address to,uint amount) external payable returns(string memory){
        require(isContract(to),"cannot be invoked by an EOA");
        (bool success, ) = to.call{value: amount}("");
        require(success,"Transaction did not take place");
        return ("transaction done");     
   }
   
   function sendEth(string memory to, uint amount) external payable returns(string memory) {
        require(address(this).balance >= amount, "This contract does not have that much amount to pay");
        require(suppliers[to].supplierAdd != address(0), "Supplier does not exist");
        if(suppliers[to].required>0){
          return "Reached Monthly requirements, amount stored in contract will be used when needed next";
        }
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

        return "Funds transfered successfully";
    }
}