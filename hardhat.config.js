/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "goerli",
  networks: {
    hardhat: {
    },
    goerli: {
      url: "https://eth-goerli.alchemyapi.io/v2/123abc123abc123abc123abc123abcde",
      accounts: [
        "adeecc35bacbb38fbde2efb09f56f3edf5b8bc4ddc2c4ab6f8f3b77be7861e80",
        "3dcf6b936eb91761aead8a3f54a9fa7abd2c864b41349d96afbc892d93c00cf5"
      ]
    }
  },
  solidity: {
    compilers: [
      {
        version: "0.8.0",
      },
      {
        version: "0.7.6",
        settings: {},
      },
    ],
  },

};