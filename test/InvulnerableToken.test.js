const { expect } = require("chai");


describe("InvulnerableToken", function () {
  let Token, token, owner, attacker;

  beforeEach(async function () {
    [owner, attacker] = await ethers.getSigners();
    const initialSupply = ethers.parseUnits("1000", 18);
    Token = await ethers.getContractFactory("InvulnerableToken");
    token = await Token.deploy(initialSupply);
  });

  it("should only allow the owner to mint tokens", async function () {
    const amount = ethers.parseUnits("500", 18);
    await expect(token.connect(attacker).mint(amount)).to.be.revertedWith(
      "Only the contract owner may mint tokens"
    );

    await token.mint(amount);
    expect(await token.balanceOf(owner.address)).to.equal(
      ethers.parseUnits("1500", 18)
    );
  });

  it("should revert transfers exceeding balance", async function () {
    const amount = ethers.parseUnits("1", 18); //more than balance
    await expect(token.connect(attacker).transfer(owner.address, amount)).to.be.revertedWith(
      "Wallet does not have sufficient funds for this transfer."
    );
  });

  it("should revert burn attempts exceeding balance", async function () {
    await expect(token.connect(attacker).burn(ethers.parseUnits("1", 18))).to.be.revertedWith(
      "Wallet does not have sufficient funds to burn this amount."
    );
  });

  it("should allow secure deposit and withdrawal", async function () {
    const amount = ethers.parseUnits("100", 18);
    await token.deposit(amount);
    await token.withdraw();

    const balance = await token.balanceOf(owner.address);
    expect(balance).to.equal(ethers.parseUnits("1000", 18));
  });
});