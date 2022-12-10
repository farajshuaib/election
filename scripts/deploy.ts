import { ethers, run } from "hardhat";

async function main() {

  const Election = await ethers.getContractFactory("Election");
  const election = await Election.deploy();

  await election.deployed();

  console.log(`deployed to ${election.address}`);

  await election.deployTransaction.wait(6);
  await election.deployed();

  await run("verify:verify", {
    address: election.address,
    contract: "contracts/Election.sol:Election",
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
