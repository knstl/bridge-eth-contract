/** @type import('hardhat/config').HardhatUserConfig */
require("@nomiclabs/hardhat-waffle")

require("dotenv").config({ path: __dirname + '/.env' });

module.exports = {
  defaultNetwork: "mynetwork",
  networks: {
    hardhat: {
    },
    mynetwork: {
      url: process.env.RPCURL,
      accounts: [
        process.env.PRIVKEY
      ]
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_APIKEY
  },
  solidity: "0.8.0"
};