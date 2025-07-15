const { expect } = require("chai");

describe("VulnerableToken", function () {
  let Token, token, owner, attacker;

  beforeEach(async function () {
    [owner, attacker] = await ethers.getSigners();
    const initialSupply = ethers.parseUnits("1000", 18);
    Token = await ethers.getContractFactory("VulnerableToken");
    token = await Token.deploy(initialSupply);
  });

  it("should underflow sender balance in transfer/ although will likely revert due to solidity runtime checks", async function () {
    await expect(token.connect(attacker).transfer(owner.address, 1)).to.be.reverted;
  });

  it("should allow anyone to mint tokens", async function () {
    const amount = ethers.parseUnits("1000000", 18);
    await token.connect(attacker).mint(amount);

    const balance = await token.balanceOf(attacker.address);
    expect(balance).to.equal(amount);
  });

  it("should underflow and corrupt totalSupply in burn/ although will likely revert due to solidity runtime checks", async function () {
    await token.connect(attacker).mint(1);
    await expect(token.connect(attacker).burn(ethers.parseUnits("1000000", 18))).to.be.reverted;
  });
});