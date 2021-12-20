# 🏗 scaffold-eth | 🏰 BuidlGuidl

## My implementation

- Deployed on https at `https://sean-eth-speed-run-1.surge.sh/`
- Deployed on IPFS at `https://ipfs.io/ipfs/Qmez2EZFJ5EzwbDkZCxNnZvpo2LHQVNEFJpmEPuR5VwoXT`

I have went through each point and added some notes beside them on how I handled them.

If redeploy run:
```bash
// If make any change to contracts
yarn deploy --network rinkeby
// Ensure `const targetNetwork = NETWORKS.rinkeby` in `App.jsx`
yarn build
yarn surge & ipfs

// If only make changes to front end
// Ensure `const targetNetwork = NETWORKS.rinkeby` in `App.jsx`
yarn build
yarn surge & ipfs
```

## 🚩 Challenge 1: 🥩 Decentralized Staking App

> 🦸 A super power of Ethereum is allowing you, the builder, to create a simple set of rules that an adversarial group of players can use to work together. In this challenge, you create a decentralized application where users can coordinate a group funding effort. If the users cooperate, the money is collected in a second smart contract. If they defect, the worst that can happen is everyone gets their money back. The users only have to trust the code.

> 🏦 Build a `Staker.sol` contract that collects **ETH** from numerous addresses using a payable `stake()` function and keeps track of `balances`. After some `deadline` if it has at least some `threshold` of ETH, it sends it to an `ExampleExternalContract` and triggers the `complete()` action sending the full balance. If not enough **ETH** is collected, allow users to `withdraw()`.

> 🎛 Building the frontend to display the information and UI is just as important as writing the contract. The goal is to deploy the contract and the app to allow anyone to stake using your app. Use a `Stake(address,uint256)` event to <List/> all stakes.

> 🏆 The final **deliverable** is deploying a decentralized application to a public blockchain and then `yarn build` and `yarn surge` your app to a public webserver. Share the url in the [Challenge 1 telegram channel](https://t.me/joinchat/E6r91UFt4oMJlt01) to earn a collectible and cred! || Part of the challenge is making the **UI/UX** enjoyable and clean! 🍾


🧫 Everything starts by ✏️ Editing `Staker.sol` in `packages/hardhat/contracts`

---
### Checkpoint 0: 📦 install 📚

```bash

git clone https://github.com/scaffold-eth/scaffold-eth-challenges.git challenge-1-decentralized-staking

cd challenge-1-decentralized-staking

git checkout challenge-1-decentralized-staking

yarn install

```

🔏 Edit your smart contract `Staker.sol` in `packages/hardhat/contracts`

---

### Checkpoint 1: 🔭 Environment 📺

You'll have three terminals up for:

`yarn start` (react app frontend)

`yarn chain` (hardhat backend)

`yarn deploy` (to compile, deploy, and publish your contracts to the frontend)

> 💻 View your frontend at http://localhost:3000/

> 👩‍💻 Rerun `yarn deploy --reset` whenever you want to deploy new contracts to the frontend.

---

### Checkpoint 2: 🥩 Staking 💵

You'll need to track individual `balances` using a mapping:
```solidity
mapping ( address => uint256 ) public balances;
```

And also track a constant `threshold` at ```1 ether```
```solidity
uint256 public constant threshold = 1 ether;
```

> 👩‍💻 Write your `stake()` function and test it with the `Debug Contracts` tab in the frontend

#### 🥅 Goals

- [x] Do you see the balance of the `Staker` contract go up when you `stake()`?
- [x] Is your `balance` correctly tracked?
- [x] Do you see the events in the `Staker UI` tab?


---

### Checkpoint 3: 🔬 State Machine / Timing ⏱

> ⚙️  Think of your smart contract like a *state machine*. First, there is a **stake** period. Then, if you have gathered the `threshold` worth of ETH, there is a **success** state. Or, we go into a **withdraw** state to let users withdraw their funds.

Set a `deadline` of ```block.timestamp + 30 seconds```
```solidity
uint256 public deadline = block.timestamp + 30 seconds;
```

👨‍🏫 Smart contracts can't execute automatically, you always need to have a transaction execute to change state. Because of this, you will need to have an `execute()` function that *anyone* can call, just once, after the `deadline` has expired.

> 👩‍💻 Write your `execute()` function and test it with the `Debug Contracts` tab

If the `address(this).balance` of the contract is over the `threshold` by the `deadline`, you will want to call: ```exampleExternalContract.complete{value: address(this).balance}()```

If the balance is less than the `threshold`, you want to set a `openForWithdraw` bool to `true` and allow users to `withdraw(address payable)` their funds.

(You'll have 30 seconds after deploying until the deadline is reached, you can adjust this in the contract.)

> 👩‍💻 Create a `timeLeft()` function including ```public view returns (uint256)``` that returns how much time is left.

⚠️ Be careful! if `block.timestamp >= deadline` you want to ```return 0;```

⏳ The time will only update if a transaction occurs. You can see the time update by getting funds from the faucet just to trigger a new block.

> 👩‍💻 You can call `yarn deploy --reset` any time you want a fresh contract

#### 🥅 Goals
- [x] Can you see `timeLeft` counting down in the `Staker UI` tab when you trigger a transaction with the faucet?
- [x] If you `stake()` enough ETH before the `deadline`, does it call `complete()`?
- [x] If you don't `stake()` enough can you `withdraw(address payable)` your funds?


---


### Checkpoint 4: 💵 Receive Function / UX 🙎

🎀 To improve the user experience, set your contract up so it accepts ETH sent to it and calls `stake()`. You will use what is called the `receive()` function.

> Use the [receive()](https://docs.soliditylang.org/en/v0.8.9/contracts.html?highlight=receive#receive-ether-function) function in solidity to "catch" ETH sent to the contract and call `stake()` to update `balances`.

---
#### 🥅 Goals
- [ ] If you send ETH directly to the contract address does it update your `balance`?

---

## ⚔️ Side Quests
- [x] Can execute get called more than once, and is that okay?
  - No, execute can now only be called once
- [x] Can you stake and withdraw freely after the `deadline`, and is that okay?
  - You cannot stake after the deadline but you can withdraw, as long as you have a balance to withdraw
- [x] What are other implications of *anyone* being able to withdraw for someone?
  - I removed the ability for anyone to withdraw, you can only withdraw your own

---

## 🐸 It's a trap!
- [x] Make sure funds can't get trapped in the contract! **Try sending funds after you have executed! What happens?**
  - Can only send funds before deadline and can only execute after deadline so not possible
- [x] Try to create a [modifier](https://solidity-by-example.org/function-modifier/) called `notCompleted`. It will check that `ExampleExternalContract` is not completed yet. Use it to protect your `execute` and `withdraw` functions.
  - Due to the change I made this doesn't really make sense

---

### Checkpoint 5: 🚢 Ship it 🚁

📡 Edit the `defaultNetwork` to [your choice of public EVM networks](https://ethereum.org/en/developers/docs/networks/) in `packages/hardhat/hardhat.config.js`

👩‍🚀 You will want to run `yarn account` to see if you have a **deployer address**

🔐 If you don't have one, run `yarn generate` to create a mnemonic and save it locally for deploying.

⛽️ You will need to send ETH to your **deployer address** with your wallet.

 >  🚀 Run `yarn deploy` to deploy your smart contract to a public network (selected in hardhat.config.js)

---

<!--## 🔍 Etherscan Contract Verification
> Get a free [Etherscan API Key](https://etherscan.io/apis) and update your hardhat.config.js file with it.

![Screen Shot 2021-11-24 at 9 13 40 AM](https://user-images.githubusercontent.com/9419140/143254420-1916d419-7477-4eec-b201-94166174d8c3.png)

> You will need to uncomment the verify task in the deploy script to verify your contract(s). We will use your verified contract to check your work 👀

![Screen Shot 2021-11-24 at 9 25 44 AM](https://user-images.githubusercontent.com/9419140/143256354-29675a6d-5e3e-421b-800f-7c35ced5e6f4.png)

 ---
-->

### Checkpoint 6: 🎚 Frontend 🧘‍♀️

 > 📝 Edit the `targetNetwork` in `App.jsx` (in `packages/react-app/src`) to be the public network where you deployed your smart contract.

> 💻 View your frontend at http://localhost:3000/

 👩‍🎤 Take time to craft your user experience...

 📡 When you are ready to ship the frontend app...

 📦  Run `yarn build` to package up your frontend.
 
 > 📝 If you plan on submitting this challenge, be sure to set your ```deadline``` to at least ```block.timestamp + 72 hours```

💽 Upload your app to surge with `yarn surge` (you could also `yarn s3` or maybe even `yarn ipfs`?)

> 📝 you will use this deploy URL to submit to [SpeedRun](https://speedrunethereum.com).

🚔 Traffic to your url might break the [Infura](https://infura.io/) rate limit, edit your key: `constants.js` in `packages/ract-app/src`.

🎖 Show off your app by pasting the url in the [Challenge 1 telegram channel](https://t.me/joinchat/E6r91UFt4oMJlt01) 🎖

---
### Checkpoint 7: 📜 Contract Verification

Update the api-key in packages/hardhat/package.json file. You can get your key [here](https://etherscan.io/myapikey).

![Screen Shot 2021-11-30 at 10 21 01 AM](https://user-images.githubusercontent.com/9419140/144075208-c50b70aa-345f-4e36-81d6-becaa5f74857.png)

> Now you are ready to run the `yarn verify --network your_network` command to verify your contracts on etherscan 🛰

---

> 🏃 Head to your next challenge [here](https://speedrunethereum.com).

> 💬 Problems, questions, comments on the stack? Post them to the [🏗 scaffold-eth developers chat](https://t.me/joinchat/F7nCRK3kI93PoCOk)
