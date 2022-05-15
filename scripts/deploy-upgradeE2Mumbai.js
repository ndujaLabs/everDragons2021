require('dotenv').config()
const hre = require("hardhat");
const ethers = hre.ethers
const deployed = require("../export/deployed.json");

const DeployUtils = require('./lib/DeployUtils')
let deployUtils

async function main() {
  deployUtils = new DeployUtils(ethers)

  const chainId = await deployUtils.currentChainId()
  let [deployer] = await ethers.getSigners();

  const network = chainId === 80001 ? 'mumbai' : 'localhost'


  if (chainId !== 80001 && chainId !== 1337) {
    process.exit();
  }

  // const secondaryChain = chainId !== 137 && chainId !== 80001 && chainId !== 1337

  console.log(
      "Deploying contracts with the account:",
      deployer.address,
      'to', network
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Everdragons2Genesis = await ethers.getContractFactory("Everdragons2Genesis")
  const everdragons2Genesis = Everdragons2Genesis.attach(deployed[chainId].Everdragons2Genesis)

  const Everdragons2GenesisV2Mumbai = await ethers.getContractFactory("Everdragons2GenesisV2Mumbai")

  await upgrades.forceImport(deployed[chainId].Everdragons2Genesis, Everdragons2Genesis);

  const upgraded = await upgrades.upgradeProxy(everdragons2Genesis.address, Everdragons2GenesisV2Mumbai);
  await upgraded.deployed();

  // everdragons2Genesis = await upgrades.upgradeProxy('0xE37760c7933176679951A5328a5Cd11fa800c60b', Everdragons2Genesis);

  // await everdragons2Genesis.deployed()
  // console.log("Everdragons2Genesis deployed to:", everdragons2Genesis.address);

//   console.log(`
// To verify Everdragons2Genesis source code:
//
//   npx hardhat verify --show-stack-traces \\
//       --network ${network} \\
//       ${everdragons2Genesis.address}
//
// `)

  // await deployUtils.saveDeployed(chainId, ['Everdragons2Genesis'], [everdragons2Genesis.address])

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

