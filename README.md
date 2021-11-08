# ICO Dapp with Liquidity Pool Support

This is a full stack dapp comprised of Solidity smart contracts for a ICO with token issuance. The project is comprised of:
- React SPA scafolded using Create React App
- Two Solidity smart contracts. One for projects and the other for the administration of projects.
- Hardhart and Ether.js
- Unit tests


# Implementation

4 smart contracts are contained in the `src/contracts` folder. These are the:
- SpaceICO: ICO Management Smart Contract
- Spacetoken: ERC20-compliant smart contract
- SpaceRouter: Liquiditing Pool router
- SpacePool: Ether and SpaceToken Liquidity Pool contract based on Uniswap V2
- Two basic unit tests in `src/test` for ICO smart contracts.

# Project Brief
The smart contract aims to raise 30,000 Ether by performing an ICO. The ICO should only be available to whitelisted private investors starting in Phase Seed with a maximum total private contribution limit of 15,000 Ether and an individual contribution limit of 1,500 Ether. The ICO should become available to the general public during Phase General, with a total contribution limit equal to 30,000 Ether, inclusive of funds raised from the private phase. During this phase, the individual contribution limit should be 1,000 Ether, until Phase Open, at which point the individual contribution limit should be removed. At that point, the ICO contract should immediately release ERC20-compatible tokens for all contributors at an exchange rate of 5 tokens to 1 Ether. The owner of the contract should have the ability to pause and resume fundraising at any time, as well as move a phase forwards (but not backwards) at will.

The project also includes support for a Uniswap v2 implementation of a Ether to Space Token Liquidity Pool.


# Ethereum configuration

To get start, try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
npx hardhat run scripts/deploy.js
node scripts/deploy.js
npx eslint '**/*.js'
npx eslint '**/*.js' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```

## Etherscan verification

To try out Etherscan verification, you first need to deploy a contract to an Ethereum network that's supported by Etherscan, such as Ropsten.

In this project, copy the .env.template file to a file named .env, and then edit it to fill in the details. Enter your Etherscan API key, your Ropsten node URL (eg from Alchemy), and the private key of the account which will send the deployment transaction. With a valid .env file in place, first deploy your contract:

```shell
hardhat run --network ropsten scripts/deploy.js
```

Then, copy the deployment address and paste it in to replace `DEPLOYED_CONTRACT_ADDRESS` in this command:

```shell
npx hardhat verify --network ropsten DEPLOYED_CONTRACT_ADDRESS "Hello, Hardhat!"
```

# React SPA

## Available Scripts

In the project directory, you can run:

### `yarn start`

Runs the app in the development mode.\
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.\
You will also see any lint errors in the console.

### `yarn test`

Launches the test runner in the interactive watch mode.\
See the section about [running tests](https://facebook.github.io/create-react-app/docs/running-tests) for more information.

### `yarn build`

Builds the app for production to the `build` folder.\
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.\
Your app is ready to be deployed!

See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

### `yarn eject`

**Note: this is a one-way operation. Once you `eject`, you can’t go back!**

If you aren’t satisfied with the build tool and configuration choices, you can `eject` at any time. This command will remove the single build dependency from your project.

Instead, it will copy all the configuration files and the transitive dependencies (webpack, Babel, ESLint, etc) right into your project so you have full control over them. All of the commands except `eject` will still work, but they will point to the copied scripts so you can tweak them. At this point you’re on your own.

You don’t have to ever use `eject`. The curated feature set is suitable for small and middle deployments, and you shouldn’t feel obligated to use this feature. However we understand that this tool wouldn’t be useful if you couldn’t customize it when you are ready for it.


