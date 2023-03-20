const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

const {ethers} = require("hardhat");
const {numberToRpcQuantity} = require("hardhat/internal/core/jsonrpc/types/base-types");
describe("Crypto Carbon Energy token", function () {


    // We define a fixture to reuse the same setup in every test. We use
    // loadFixture to run this setup once, snapshot that state, and reset Hardhat
    // Network to that snapshot in every test.
    async function deployTokenFixture() {
      // Get the ContractFactory and Signers here.
      const Token = await ethers.getContractFactory("CryptoCarbonEnergy");
      const [owner, addr1, addr2] = await ethers.getSigners();

      // To deploy our contract, we just have to call Token.deploy() and await
      // its deployed() method, which happens once its transaction has been
      // mined.
      const cyceToken = await Token.deploy();

      await cyceToken.deployed();

      // Fixtures can return anything you Ïconsider useful for your tests
      return { Token, cyceToken, owner, addr1, addr2 };
    }


  describe("Deployment", function () {
    // `it` is another Mocha function. This is the one you use to define each
    // of your tests. It receives the test name, and a callback function.
    //
    // If the callback function is async, Mocha will `await` it.
    it("Should set the right owner", async function () {
      // We use loadFixture to setup our environment, and then assert that
      // things went well
      const { cyceToken, owner } = await loadFixture(deployTokenFixture);

      // `expect` receives a value and wraps it in an assertion object. These
      // objects have a lot of utility methods to assert values.

      // This test expects the owner variable stored in the contract to be
      // equal to our Signer's owner.
      expect(await cyceToken.owner()).to.equal(owner.address);
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const { cyceToken, owner } = await loadFixture(deployTokenFixture);
      await  cyceToken.mint(owner.address, 1000)
      const ownerBalance = await cyceToken.balanceOf(owner.address);
      expect(await cyceToken.totalSupply()).to.equal(ownerBalance);
    });


  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      const { cyceToken, owner, addr1, addr2 } = await loadFixture(
          deployTokenFixture
      );
     await  cyceToken.mint(owner.address, 1000)
    /* balance = await cyceToken.balanceOf(owner.address);
     console.log(Number(balance));*/
      // Transfer 50 tokens from owner to addr1
      await expect(
          cyceToken.transfer(addr1.address, 50)
      ).to.changeTokenBalances(cyceToken, [owner, addr1], [-50, 50]);

      // Transfer 50 tokens from addr1 to addr2
      // We use .connect(signer) to send a transaction from another account
      await expect(
          cyceToken.connect(addr1).transfer(addr2.address, 50)
      ).to.changeTokenBalances(cyceToken, [addr1, addr2], [-50, 50]);
    });

    it("should emit Transfer events", async function () {
      const { cyceToken, owner, addr1, addr2 } = await loadFixture(
          deployTokenFixture
      );
     await  cyceToken.mint(owner.address, 1000)
      // Transfer 50 tokens from owner to addr1
      await expect(cyceToken.transfer(addr1.address, 100))
          .to.emit(cyceToken, "Transfer")
          .withArgs(owner.address, addr1.address, 100);

      // Transfer 50 tokens from addr1 to addr2
      // We use .connect(signer) to send a transaction from another account
      await expect(cyceToken.connect(addr1).transfer(addr2.address, 20))
          .to.emit(cyceToken, "Transfer")
          .withArgs(addr1.address, addr2.address, 20);
    });

    it("Should fail if sender doesn't have enough tokens", async function () {
      const { cyceToken, owner, addr1 } = await loadFixture(
          deployTokenFixture
      );
     await  cyceToken.mint(owner.address, 1000)
      const initialOwnerBalance = await cyceToken.balanceOf(owner.address);

      // Try to send 1 token from addr1 (0 tokens) to owner.
      // `require` will evaluate false and revert the transaction.
      await expect(
          cyceToken.connect(addr1).transfer(owner.address, 1)
      ).to.be.revertedWith('ERC20: transfer amount exceeds balance');

      // Owner balance shouldn't have changed.
      expect(await cyceToken.balanceOf(owner.address)).to.equal(
          initialOwnerBalance
      );

    });
    it("Blakclist Add blaclist remove, unautrized", async function () {
      const { cyceToken, owner, addr1 } = await loadFixture(
          deployTokenFixture
      );
     await  cyceToken.mint(owner.address, 1000)
      const initialOwnerBalance = await cyceToken.balanceOf(owner.address);


      await expect(
          cyceToken.transfer(addr1.address, 500)
      ).to.changeTokenBalances(cyceToken, [owner, addr1], [-500, 500]);



      await expect(
          cyceToken.connect(addr1).addBlacklist(addr1.address)
      ).to.be.revertedWith('Unauthorized');
      let result = await  cyceToken.addBlacklist(addr1.address)

      await expect(true).to.equal(await cyceToken.blackListed(addr1.address));
      await expect(
          cyceToken.connect(addr1).transfer(owner.address, 50)
      ).to.be.revertedWith('Action: Sender blacklisted');

      await expect(
          cyceToken.transfer(addr1.address, 50)
      ).to.be.revertedWith('Action: Recipient blacklisted');

      await  cyceToken.removeBlacklist(addr1.address)

      await expect(
          cyceToken.transfer(addr1.address, 0)
      ).to.be.revertedWith('Action: transfer amount has to big than 0');


      await  expect(false).to.equal(await cyceToken.blackListed(addr1.address));
      await expect(
          cyceToken.transfer(addr1.address, 50)
      ).to.changeTokenBalances(cyceToken, [owner, addr1], [-50,50])


    });
    it("Pause event", async function () {
      const { cyceToken, owner, addr1, addr2 } = await loadFixture(
          deployTokenFixture
      );
     await  cyceToken.mint(owner.address, 1000)
      await  cyceToken.pause();

      // Transfer 50 tokens from owner to addr1
      await expect(cyceToken.transfer(addr1.address, 100))
          .to.be.revertedWith('Action: paused');
      await  cyceToken.unpause();

      console.log(cyceToken.address)
      await cyceToken.transfer(cyceToken.address, 100)
     // await  cyceToken.transferOwnerShip(addr1.address);
     //  await  cyceToken.connect(addr1).transferOwnerShip(addr1.address);
      //await  cyceToken.renounceOwnerShip();
      console.log(await cyceToken.owner(), 1)
      //await  cyceToken.connect(addr1).pause();

    });
    it("Deploy et " , async () => {
      Token = await ethers.getContractFactory("CryptoCarbonEnergy");
      token = await Token.deploy();
      [owner, addr1, addr2, _] = await ethers.getSigners();

    })
    it('owner hesabının bakiyesini kontrol et', async function () {
      let balance ;
      await token.mint(owner.address, 100000)
      //await  token.mint(30000000000000);
      balance = await token.balanceOf(owner.address);

    });

    it('owner hesabının bakiyesini transfer et', async function () {
      let balance ;
      await token.transfer(addr1.address, 1000)
      //await  token.mint(30000000000000);
      balance = await token.balanceOf(owner.address);
      totalSupply = await token.totalSupply();


      balance = await token.balanceOf(addr1.address);

    });
    it('1000 adet token yak ', async function () {
      let totalSupply ;
      // await token.transferOwnerShip(addr1.address);
      //await token.connect(addr1).burn(1000)
      //await  token.mint(30000000000000);

      totalSupply = await token.totalSupply();


    });

    it('karalisteye al ', async function () {
      let balance ;
      await token.addBlacklist(addr1.address);

      expect(true).to.equal(await token.blackListed(addr1.address))
      await token.removeBlacklist(addr1.address);
      expect(false).to.equal(await token.blackListed(addr1.address))
      //await token.connect(addr1).transfer(addr2.address, 1000)
      //await  token.mint(30000000000000);

    });


    it('Pause Yap', async function () {
      let balance ;
      await token.pause();
      //expect('Action: paused') .to.equal  await  token.transfer(addr1.address, 100)
      expect(true).to.equal(await  token.paused());

    });
    it('UnPause Yap', async function () {
      let balance ;
      await  token.unpause()
      await  token.transfer(addr1.address, 100)

      expect(false).to.equal(await  token.paused())

    });
  });
});
});

