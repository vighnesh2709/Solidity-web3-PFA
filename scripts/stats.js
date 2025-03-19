//Ether Scan
// Get latest block by timestamp
// Get block number details and the timestamp details. to get average block time. 
// Gas Oracle for gas price tracking
// Etherscan API Key Token : \

// Poly Scan
// Same can be done for timestamp and all that for polygon
// And Gas Oracle also 
// PolyScan API Key Token : \



const axios = require('axios');
const fs = require('fs');
const { Web3 } = require("web3");

const web3 = new Web3();

let API_KEY = "E7JX6R6GF9ICFGBR9H49S9356YH5TV9GVY";
let API_KEY_2 = "7XEKJUG6FGMYZFRWVSTMZ2BYI4CC42CQJV";

// Store previous block data globally
// async function ethData() {

// try {
//     let timestamp = Math.floor(Date.now() / 1000);

//     // Get latest block number by timestamp
//     const url1 = `https://api.etherscan.io/api?module=block&action=getblocknobytime&timestamp=${timestamp}&closest=before&apikey=${API_KEY}`;
//     const response1 = await axios.get(url1);

//     let blockNo = response1.data.result;
//     if (!blockNo) {
//         console.error("Failed to retrieve block number.");
//         return;
//     }
//     console.log("Block Number:", blockNo);

//     // Get block details to fetch timestamp
//     const url2 = `https://api.etherscan.io/api?module=block&action=getblockreward&blockno=${blockNo}&apikey=${API_KEY}`;
//     const response2 = await axios.get(url2);

//     let blockTime = parseInt(response2.data.result.timeStamp);
//     console.log("Block Timestamp:", blockTime);

//     // Calculate average block time
//     if (previousBlock && previousTimestamp) {
//         let blockDiff = blockNo - previousBlock;
//         let timeDiff = blockTime - previousTimestamp;

//         if (timeDiff > 0 && blockDiff > 0) {
//             let avgBlockTime = timeDiff / blockDiff;
//             console.log(`Average Block Time: ${avgBlockTime.toFixed(2)} seconds`);
//         }
//     }

//     // Update previous values
//     previousBlock = blockNo;
//     previousTimestamp = blockTime;

// } catch (error) {
//     console.error("Error:", error);
// }
// }
let path = '/home/vighnesh/Desktop/Solidity-web3-PFA/scripts/eth.csv'
async function ethData() {
    try {
        const url1 = `https://api.etherscan.io/api?chainid=1&module=gastracker&action=gasoracle&apikey=${API_KEY}`;
        const valUrl = `https://api.etherscan.io/v2/api?chainid=1&module=stats&action=ethprice&apikey=${API_KEY}`;

        let response = await axios.get(url1);
        let response2 = await axios.get(valUrl);

        if (response.data.status === "1") { // Check if API response is successful
            let safeGasPrice = response.data.result.SafeGasPrice;
            let proposeGasPrice = response.data.result.ProposeGasPrice;
            let fastGasPrice = response.data.result.FastGasPrice;
            let suggestedBase = response.data.result.suggestBaseFee; 
            
            let ethUsdPrice = response2.data.result.ethusd;
            
            let safeGasPriceEth = web3.utils.fromWei(web3.utils.toWei(safeGasPrice, 'gwei'), 'ether');
            let proposeGasPriceEth = web3.utils.fromWei(web3.utils.toWei(proposeGasPrice, 'gwei'), 'ether');
            let fastGasPriceEth = web3.utils.fromWei(web3.utils.toWei(fastGasPrice, 'gwei'), 'ether');
            let suggestedBaseEth = web3.utils.fromWei(web3.utils.toWei(suggestedBase, 'gwei'), 'ether');
            
      
            // Calculate USD values using web3 conversions
            let safeGasPriceUsd = parseFloat(safeGasPriceEth) * ethUsdPrice;
            let proposeGasPriceUsd = parseFloat(proposeGasPriceEth) * ethUsdPrice;
            let fastGasPriceUsd = parseFloat(fastGasPriceEth) * ethUsdPrice;
            let suggestedBaseUsd = parseFloat(suggestedBaseEth) * ethUsdPrice;
            
            let timestamp = Math.floor(Date.now() / 1000);
            
            // Format for CSV with appropriate precision
            let csvRow = `${timestamp},${safeGasPriceEth},${proposeGasPriceEth},${fastGasPriceEth},${suggestedBaseEth},${safeGasPriceUsd},${proposeGasPriceUsd},${fastGasPriceUsd},${suggestedBaseUsd},${ethUsdPrice}\n`;
            
            fs.appendFileSync(path, csvRow, 'utf8');
            console.log("Data appended:", csvRow.trim());
        } else {
            console.error("Error fetching gas price:", response.data.message);
        }
    } catch (error) {
        console.error("Error:", error);
    }
}
let path2 = '/home/vighnesh/Desktop/Solidity-web3-PFA/scripts/poly.csv'
async function PolyData() {
    try {
        const url1 = `https://api.polygonscan.com/api?module=gastracker&action=gasoracle&apikey=${API_KEY_2}`;
        const valUrl2 = `https://api.polygonscan.com/api?module=stats&action=maticprice&apikey=${API_KEY_2}`;

        let response = await axios.get(url1);
        let response2 = await axios.get(valUrl2);

        if (response.data.status === "1") { // Check if API response is successful
            let safeGasPrice = response.data.result.SafeGasPrice;
            let proposeGasPrice = response.data.result.ProposeGasPrice;
            let fastGasPrice = response.data.result.FastGasPrice;
            let suggestedBase = response.data.result.suggestBaseFee; 
            
            let PolyUsdPrice = (response2.data.result.maticusd);

            let safeGasPricePoly = web3.utils.fromWei(web3.utils.toWei(safeGasPrice, 'gwei'), 'ether');
            let proposeGasPricePoly = web3.utils.fromWei(web3.utils.toWei(proposeGasPrice, 'gwei'), 'ether');
            let fastGasPricePoly = web3.utils.fromWei(web3.utils.toWei(fastGasPrice, 'gwei'), 'ether');
            let suggestedBasePoly = web3.utils.fromWei(web3.utils.toWei(suggestedBase, 'gwei'), 'ether');
            
      
            // Calculate USD values using web3 conversions
            let safeGasPriceUsd = parseFloat(safeGasPricePoly) * PolyUsdPrice;
            let proposeGasPriceUsd = parseFloat(proposeGasPricePoly) * PolyUsdPrice;
            let fastGasPriceUsd = parseFloat(fastGasPricePoly) * PolyUsdPrice;
            let suggestedBaseUsd = parseFloat(suggestedBasePoly) * PolyUsdPrice;
            
            let timestamp = Math.floor(Date.now() / 1000);
            
            // Format for CSV with appropriate precision
            let csvRow = `${timestamp},${safeGasPricePoly},${proposeGasPricePoly},${fastGasPricePoly},${suggestedBasePoly},${safeGasPriceUsd},${proposeGasPriceUsd},${fastGasPriceUsd},${suggestedBaseUsd},${PolyUsdPrice}\n`;
            
            fs.appendFileSync(path2, csvRow, 'utf8');
            console.log("Data appended:", csvRow.trim());
        } else {
            console.error("Error fetching gas price:", response.data.message);
        }
    } catch (error) {
        console.error("Error:", error);
    }
}

setInterval(ethData, 12000);
setInterval(PolyData, 12000);