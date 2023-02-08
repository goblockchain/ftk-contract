const { ethers } = require("hardhat");

async function main() {
  const [deployer, acc1, acc2] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Token = await ethers.getContractFactory("COPF");
  const token = await Token.deploy(deployer.address, acc2.address, 0, 2023, 2025,1,"https://ipfs.com", "first_asset", {gasLimit: 3e7});

  console.log("Token address:", token.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
