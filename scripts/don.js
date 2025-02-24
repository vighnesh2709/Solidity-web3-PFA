const fs = require("fs");
const { Web3 } = require("web3");
const { performance } = require('perf_hooks');


const web3 = new Web3('http://127.0.0.1:8545');

let contractPath = '/home/vighnesh/Desktop/Solidity-web3-PFA/build/contracts/ReceiveDonation.json';
let contractJSON = JSON.parse(fs.readFileSync(contractPath, 'utf8'));

const { abi, bytecode } = contractJSON;


async function deployContract() {
  try {
    const accounts = await web3.eth.getAccounts();
    const deployerAccount = accounts[0];

    const contract = new web3.eth.Contract(abi);

    const deploy = contract.deploy({
      data: bytecode, // Bytecode of the contract
      arguments: [] // Constructor arguments, if any
    });

    const receipt = await deploy.send({
      from: deployerAccount,
      gas: 1500000,  // Adjusted gas limit
      gasPrice: "300000000000",
      value: web3.utils.toWei('1','ether'),
    });
    // console.log("Contract deployed at:", receipt.options.address);
    const deployedContract = new web3.eth.Contract(abi, receipt.options.address);

    let totalTransaction = 3;
    let startTime = performance.now();

    let ans = await deployedContract.methods.checkValue(receipt.options.address).call();
    // console.log("Check Value:", ans.toString());

    let ans1 = await deployedContract.methods.addSupplier(accounts[1],web3.utils.toWei('1','ether'),"Food").send({from: deployerAccount,gas:500000});
    // console.log(ans1)
    totalGas=ans1.gasUsed*ans1.effectiveGasPrice

    let ans2 = await deployedContract.methods.sendEth('Food',web3.utils.toWei('1',"ether")).send({from: deployerAccount,gas:500000});
    // console.log(ans2.toString())
    let check = ans2.gasUsed*ans2.effectiveGasPrice
    totalGas+=check

    let ans3 = await deployedContract.methods.checkValue(accounts[1]).call()
    // console.log(ans3.toString());

    let ans4 = await deployedContract.methods.checkValue(receipt.options.address).call();
    // console.log("Check Value:", ans4.toString());
    
    
    
    let endTime = performance.now()
    let elapseTime = (endTime-startTime)/1000
    let tps = totalTransaction/elapseTime
    let gasCostInEther = web3.utils.fromWei(totalGas,'ether')
    console.log(new Date(Number((await web3.eth.getBlock("latest")).timestamp) * 1000).toLocaleString());
    // console.log("Gas cost: ",web3.utils.fromWei(totalGas,'ether'))
    // console.log(`Total Transactions: ${totalTransaction}`);
    // console.log(`Elapsed Time: ${elapseTime.toFixed(4)} seconds`);
    // console.log(`Throughput (TPS): ${tps.toFixed(4)}`);

    const csvData = `${gasCostInEther},${totalTransaction},${elapseTime.toFixed(4)},${tps.toFixed(4)}\n`;
    fs.appendFileSync('eth.csv',csvData,'utf-8');
    // console.log("Data weitten");
  } catch (error) {
    console.error("Error deploying contract:", error);
  }
  
}



setInterval(() => {
    deployContract();
  }, 1000);
// contractActions();