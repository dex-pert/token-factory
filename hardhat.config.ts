import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@nomiclabs/hardhat-ethers'
import * as dotenv from 'dotenv';
import { ethers } from "hardhat";
dotenv.config();

const DEFAULT_COMPILER_SETTINGS = {
  version: '0.8.24',
  settings: {
    viaIR: true,
    optimizer: {
      enabled: true,
      runs: 1_000_000,
    },
    metadata: {
      bytecodeHash: 'none',
    },
  },
}

export default {
  paths: {
    sources: './contracts',
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: false,
      chainId: 1,
      forking: {
        url: `https://eth-mainnet.g.alchemy.com/v2/kNPJaYqMx7BA9TcDDJQ8pS5WcLqXGiG7`,
        // url: `https://rpc.bitlayer.org`,
      },
    },
    mainnet: {
      url: `https://1rpc.io/eth`,
      accounts: [process.env.deployKey]
    },
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/gOeoBV9mlFL1pWj7qbKEdlB6pXTfNum6`,
      accounts: ["8dbc9d7b924b00532e6fc1295fd120886d3d3576ef9ac9de78335de33c28b095"]
    },
    base: {
      url: `https://base.llamarpc.com`,
      accounts: ["2f750870f474e1af076f10160b50daf05d948942e5a22eff28b483795de33550"]
    },
    bitLayerTestnet: {
      url: `	https://testnet-rpc.bitlayer.org`,
      accounts: ["ddf0d87c8364f888ce8cea57995781797bbd954441deae412ae7922ad0813a9f"],
    },
    bitlayer: {
      url: `	https://rpc.bitlayer.org`,
      accounts: [process.env.deployKey],
    },
    confluxTestnet: {
      url: `https://evmtestnet.confluxrpc.com`,
      accounts: ["8dbc9d7b924b00532e6fc1295fd120886d3d3576ef9ac9de78335de33c28b095"]
    },
    confluxMainnet: {
      url: `https://evm.confluxrpc.com`,
      accounts: [process.env.confluxKey]
    },
    neoxTestnet: {
      url: `https://testnet.rpc.banelabs.org/`,
      accounts: ["227e38b12814302308de3d564c27589b934c893f412405364e4bd6fa152d4415"]
    },
    fiveiretestnet: {
      url: 'https://rpc.testnet.5ire.network',
      accounts: ["0x418776e270e22baa51cc1ac0919333ce84ab17e7135303b6aa988e934abac940"]
    },
    fiveire: {
      url: 'https://rpc.5ire.network',
      accounts: [process.env.deployKey]
    },
    neox: {
      url: 'https://mainnet-1.rpc.banelabs.org',
      accounts: [process.env.deployKey],
    },
    mantaMainnet: {
      url: "https://manta-pacific.drpc.org",
      accounts: [process.env.deployKey]
    }
  },
  namedAccounts: {
    deployer: 0,
  },
  solidity: {
    compilers: [DEFAULT_COMPILER_SETTINGS],
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  },
  mocha: {
    timeout: 60000,
  },
  etherscan: {
    apiKey: {
      mainnet: 'QEAE2M96IB94MVPUN7ESQEBNI416F1EWRR',
      sepolia: 'QEAE2M96IB94MVPUN7ESQEBNI416F1EWRR',
      bitLayerTestnet: "1234",
      bitlayer:"123",
      fiveire: "fiveire",
      confluxTestnet: 'espace',
      confluxMainnet: 'espace',
      neoxTestnet: "123",
      neox: "neox",
      mantaMainnet: "test",
    },
    customChains: [
      {
        network: "bitLayerTestnet",
        chainId: 200810,
        urls: {
          apiURL: "https://api-testnet.btrscan.com/scan/api",
          browserURL: "https://testnet.btrscan.com/"
        }
      },
      {
        network: "bitlayer",
        chainId: 200901,
        urls: {
          apiURL: "https://api.btrscan.com/scan/api",
          browserURL: "https://www.btrscan.com/"
        }
      },
      {
        network: "fiveire",
        chainId: 995,
        urls: {
          apiURL: "https://api.evm.scan.5ire.network",
          browserURL: "https://5irescan.io"
        }

      },
        {
          network: 'confluxTestnet',
          chainId: 71,
          urls: {
            apiURL: 'https://evmapi-testnet.confluxscan.io/api/',
            browserURL: 'https://evmtestnet.confluxscan.io/',
          },
        },
        {
          network: 'confluxMainnet',
          chainId: 1030,
          urls: {
            apiURL: 'https://evmapi.confluxscan.io/api/',
            browserURL: 'https://evm.confluxscan.io/',
          },
        },
        {
          network: 'neoxTestnet',
          chainId: 12227332,
          urls: {
            apiURL: 'https://evmapi.confluxscan.io/api/',
            browserURL: 'https://xt4scan.ngd.network',
          },
        },
        {
          network: "neox",
          chainId: 47763,
          urls: {
            apiURL: "https://xexplorer.neo.org/api",
            browserURL: "https://xexplorer.neo.org/"
          }
        },
        {
          network: "mantaMainnet",
          chainId: 169,
          urls: {
            apiURL: "https://manta-pacific.calderaexplorer.xyz/api",
            browserURL: "https://manta-pacific.calderaexplorer.xyz",
          },
        },
    ]
  },
}

