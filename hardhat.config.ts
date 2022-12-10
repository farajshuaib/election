import { HardhatUserConfig } from "hardhat/config";
import dotenv from "dotenv";
import "@nomicfoundation/hardhat-toolbox";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  mocha: {
    timeout: 40000,
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY || "",
  },
  networks: {
    hardhat: {
      chainId: 1337,
    },
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${process.env.PROJECT_ID}`,
      accounts: [process.env.PRIVATE_KEY || ""],
      gas: "auto",
      gasPrice: "auto",
    },
    mainnet: {
      url: `https://eth-goerli.g.alchemy.com/v2/${process.env.PROJECT_ID}`,
      accounts: [process.env.PRIVATE_KEY || ""],
      gas: "auto",
      gasPrice: "auto",
    },
  },
};

export default config;
