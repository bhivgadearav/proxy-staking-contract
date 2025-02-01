# Proxy Staking Contracts
**Note** - Only the ETH staking contracts implementation transparent proxy pattern using openzeppelin contracts, rest are written completely by me.

This project contains three upgradable staking contracts:

1. **Native ETH Staking**: Allows users to stake their native ETH.
2. **ERC20 Token Staking**: Allows users to stake ERC20 tokens.
3. **NFT Staking**: Allows users to stake NFTs.

## Features

- **Upgradable Contracts:** All staking contracts are upgradable, ensuring flexibility and future enhancements.
- **Secure Staking:** Implements secure staking mechanisms for ETH, ERC20 tokens, and NFTs.
- **Foundry Framework:** Utilizes the Foundry framework for development, testing, and deployment.
- **Openzeppelin Contracts Used:** ERC20, IERC20, StorageSlot, IERC721

## Rewards Calculation

- **Formula**: ((block.timestamp - lastUpdateInStakedAmount) * dailyReward * stakers[_user].amount) / (1 days * 1 ether).

**Note** - Consider changing the formula for erc20 staking contract as it was made originally eth staking.

## Prerequisites

- [Foundry](https://github.com/gakonst/foundry) installed

## Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/bhivgadearav/proxy-staking-contract.git
    cd proxy-staking-contract
    ```

2. Install openzeppelin contracts:
    ```sh
    forge install OpenZeppelin/openzeppelin-contracts
    ```

3. Build the project:
    ```sh
    forge build
    ```

### Running Tests

Run the tests to ensure everything is working correctly:
```sh
forge test
```

Run the tests and get more detailed logs:
```sh
forge test -vvvvvvvvvvvvv
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under *The Unlicense*.