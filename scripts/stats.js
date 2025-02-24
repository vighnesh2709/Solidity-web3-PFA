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

let API_KEY = "";
let API_KEY_2 = "";

// Store previous block data globally
let previousBlock = null;
let previousTimestamp = null;

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

        let response = await axios.get(url1);

        if (response.data.status === "1") { // Check if API response is successful
            let SafeGasPrice = response.data.result.SafeGasPrice;
            let ProposeGasPrice = response.data.result.ProposeGasPrice;
            let FastGasPrice = response.data.result.FastGasPrice;
            let SuggestedBase = response.data.result.suggestBaseFee;
            let timestamp = Math.floor(Date.now() / 1000); // Unix timestamp for tracking

            let csvRow = `${timestamp},${SafeGasPrice},${ProposeGasPrice},${FastGasPrice},${SuggestedBase}\n`;
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

        let response = await axios.get(url1);

        if (response.data.status === "1") { // Check if API response is successful
            let SafeGasPrice = response.data.result.SafeGasPrice;
            let ProposeGasPrice = response.data.result.ProposeGasPrice;
            let FastGasPrice = response.data.result.FastGasPrice;
            let SuggestedBase = response.data.result.suggestBaseFee;
            let timestamp = Math.floor(Date.now() / 1000); // Unix timestamp for tracking

            let csvRow = `${timestamp},${SafeGasPrice},${ProposeGasPrice},${FastGasPrice},${SuggestedBase}\n`;
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
