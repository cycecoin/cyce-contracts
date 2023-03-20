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
        return {Token, cyceToken, governanceContract, owner, addr1, addr2, addr3, addr4, addr5};
    }


    describe("Deployment", function () {

        it("Should set transferownership", async function () {
            // We use loadFixture to setup our environment, and then assert that
            // things went well
            const {cyceToken, owner, governanceContract, addr1, addr2, addr3, addr4, addr5} = await loadFixture(deployTokenFixture);
            await cyceToken.mint(governanceContract.address, 1000)
            await cyceToken.transferOwnership(governanceContract.address)
            //await cyceToken.unpause()
         //  expect(await cyceToken.transferOwnership(governanceContract.address)).to.equal(true)
            await governanceContract.mint(100)
           console.log(await cyceToken.balanceOf(governanceContract.address));
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