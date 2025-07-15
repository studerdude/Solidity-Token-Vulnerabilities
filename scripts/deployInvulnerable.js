const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  const initialSupply = hre.ethers.parseUnits("1000", 18);
  const Token = await ethers.getContractFactory("InvulnerableToken");
  const token = await Token.deploy(initialSupply);
  console.log("InvulnerableToken deployed to:", token.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});