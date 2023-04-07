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

        const [owner, addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners();
        const TargetType = {   MINT : 0,
            BURN : 1,
            PAUSE : 2,
            UN_PAUSE :3,
            TRANSFER_OWNERSHIP : 4,
            ADD_BLACKLIST : 5,
            REMOVE_BLACKLIST : 6}
        // To deploy our contract, we just have to call Token.deploy() and await
        // its deployed() method, which happens once its transaction has been
        // mined.
        const cyceToken = await Token.deploy();
        await cyceToken.deployed();

        const Governance = await ethers.getContractFactory("Governance");
        const governanceContract = await Governance.deploy(cyceToken.address, [addr1.address, addr2.address, addr3.address, addr4.address, addr5.address]);

        await governanceContract.deployed();

       // await cyceToken.mint(owner.address, 1000)
        console.log(await cyceToken.owner(), owner.address);

        // Fixtures can return anything you Ïconsider useful for your tests
        return {TargetType, Token, cyceToken, governanceContract, owner, addr1, addr2, addr3, addr4, addr5};
    }


    describe("Deployment", function () {

        it("Should set transferownership", async function () {
            // We use loadFixture to setup our environment, and then assert that
            // things went well
            const {TargetType, cyceToken, owner, governanceContract, addr1, addr2, addr3, addr4, addr5} = await loadFixture(deployTokenFixture);
            await cyceToken.mint(addr1.address, 1000)
            await cyceToken.transferOwnership(governanceContract.address)
            //await cyceToken.unpause()
         //  expect(await cyceToken.transferOwnership(governanceContract.address)).to.equal(true)
          //  await governanceContract.connect(addr1)["startVoting(uint8)"](TargetType.PAUSE);

           // await governanceContract.connect(addr1)["startVoting(uint8,address,uint256)"](TargetType.MINT, addr1.address, 1000);
            await governanceContract.connect(addr1)["startVoting(uint8,address)"](TargetType.TRANSFER_OWNERSHIP, addr1.address);
            await governanceContract.connect(addr1).vote(false);
            await governanceContract.connect(addr2).vote(true);
            await governanceContract.connect(addr3).vote(true);
            await governanceContract.connect(addr4).vote(true);
            await governanceContract.connect(addr5).vote(false);
            await network.provider.send("evm_increaseTime", [3600 * 24 * 180])
            await network.provider.send("evm_mine")
            await expect(
                 governanceContract.connect(addr1).endVoting()
            ).to.be.revertedWith('Ownable: New owner address is not a contract');
          //  console.log(await governanceContract.targetType())

            await governanceContract.connect(addr1).resetVoting();
            console.log(await governanceContract.isVotingOpen())
           console.log(await cyceToken.balanceOf(addr1.address));
            expect(await cyceToken.owner()).to.equal(governanceContract.address);
        });

        it("Should assign the total supply of tokens to the owner", async function () {
            const {cyceToken, owner} = await loadFixture(deployTokenFixture);
            await cyceToken.mint(owner.address, 1000)
            const ownerBalance = await cyceToken.balanceOf(owner.address);
            expect(await cyceToken.totalSupply()).to.equal(ownerBalance);
        });
    });
});