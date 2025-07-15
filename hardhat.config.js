require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");

const { PRIVATE_KEY, RPC_URL } = process.env;

module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {},
    testnet: {
      url: RPC_URL,
      accounts: [PRIVATE_KEY],
    },
  },
};