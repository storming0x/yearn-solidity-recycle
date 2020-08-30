# Yearn Recycle

A contract that recycles all your [DAI, USDC, USDT, TUSD, yCRV] into yCRV and further into yUSD vault.
Based on @banteg initial implementation in here: https://github.com/banteg/yearn-recycle

## Usage

You need to grant allowances on up to five tokens to this contract before using it. This needs to be done for all non-zero amount and it only needs to be done once.

## Getting Started

### Dependencies

| **Service/Package** | **Version** |
| ------------------- | ----------- |
| node                | v10.22.0    |
| npm                 | v6.14.6     |
| solidity            | 0.6.10      |
| ganache-core        | v2.10.1     |
| solidity-coverage   | v0.7.10     |
| yarn                | v1.22.4     |
| python              | 2.7.15      |

### Installation process

Verify that the dependencies are properly installed.

- In order to setup on local, run

  ```sh
  yarn install
  ```

- Add the `MNEMONIC` and the `INFURA_API_KEY` to the `.env`. Refer to the `.env.example`.


- Install `yarn` for the specific version

  ```sh
  npm install -g yarn
  ```

### To compile the contracts

Run,

```sh
yarn compile
```

***Note:** This command compiles the contracts and adds the artifacts to the `/artifacts`. It also creates `/cache` to cache the specified solidity compiler and configurations.*

### To perform build

Run,

```sh
yarn build
```

### To run tests

Run,

```sh
yarn test
```

### To run coverage

Run,

```sh
yarn coverage
```

***Note:** Make sure that the artifacts already exist. If not then follow [Build](#to-perform-build).*

### To Deploy contracts

- For Local; Run,

  Open another terminal and run,

  ```sh
  yarn run node
  ```

  In main terminal run,

  ```sh
  yarn deploy:dev
  ```

- For Rinkeby; Run,

  ```sh
  yarn deploy:rinkeby
  ```

  ***Note:** Make sure that the `MNEMONIC` and the `INFURA_API_KEY` are added to the `.env`. Refer to the `.env.example`.*

### To perform cleanup

Run,

```sh
yarn clean
```

### To perform linting and prettify

- For Solidity linting; Run,

  ```sh
  yarn lint:sol
  ```

- For Typescript linting; Run,

  ```sh
  yarn lint:ts
  ```

- For Prettifying; Run,

  ```sh
  yarn prettier
  ```

## Contribute

TBD
