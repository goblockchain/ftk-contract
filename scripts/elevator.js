const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Elevator = await ethers.getContractFactory("Elevator");
  const elevator = await Elevator.deploy({gasLimit: 3e7});

  console.log("Elevator address:", elevator.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
