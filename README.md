# EthStarter CrowdFunding Dapp

This is a full stack dapp comprised of Solidity smart contracts for a Eth Kickstarter clone. The project is comprised of:
- React SPA scafolded using Create React App
- Two Solidity smart contracts. One for projects and the other for the administration of projects.
- Hardhart and Ether.js
- Unit tests


# Implementation

Two smart contracts are contained in the `src/contracts` folder. These are the:
- EthStarter: Factory contract for creating projects.
- EthProject: Crowdfunding project contracts that implements a portion of ERC721 for token minting based on contributions.
- Two basic unit tests in `src/test` for both smart contracts. The test coverage is very low and I'll be adding more tests in the future.

# Project Brief
- The smart contract is reusable; multiple projects can be registered and accept ETH concurrently.
- The goal is a preset amount of ETH.
  - This cannot be changed after a project gets created.
- Regarding contributing:
  - The contribute amount must be at least 0.01 ETH.
  - There is no upper limit.
  - Anyone can contribute to the project, including the creator.
  - One address can contribute as many times as they like.
- Regarding tiers:
  - There are three tiers.
  - Bronze tier is granted to anyone contribution.
  - Silver tier is granted to a total contribution of at least 0.25 ETH.
  - Gold tier is granted to a total contribution of at least 1 ETH.
  - Tiers should be granted immediately so other apps can read them.
  - "Total contribution" is scoped per-project (like kickstarter).
- If the project is not fully funded within 30 days:
  - The project goal is considered to have failed.
  - No one can contribute anymore.
  - Supporters get their money back.
  - Tier grants are revoked.
- Once a project becomes fully funded:
  - No one else can contribute (however, the last contribution can go over the goal).
  - The creator can withdraw any percentage of contributed funds.
- The creator can choose to cancel their project before the 30 days are over, which has the same effect as a project failing.



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


