
const zos = require('zos-lib')

const BigNumber = web3.utils.BN;
const RetentionMock = artifacts.require('Retention');
const SignatureBorderCrossingMock = artifacts.require('SignatureBorderCrossing');
const { ether, balance, expectEvent, shouldFail } = require('openzeppelin-test-helpers');

contract('Retention', function (accounts) {

  let mockRetention, mockSignatureBorderCrossing;

  const [
    ownerRetention,
    ownerSignatureBorderCrossing,
	newOwner,
    authenticatedUser,
    anyone
  ] = accounts;

  before(async function () {
    mockSignatureBorderCrossing = await SignatureBorderCrossingMock.new({ from: ownerSignatureBorderCrossing });
    mockRetention = await RetentionMock.new({ from: ownerRetention });
    await mockRetention.initialize(mockSignatureBorderCrossing.address, { from: ownerRetention })
  });
  
  context('in normal conditions', () => {
       it('an authorized user can stake ethers', async function () {	
	      const amount = ether('23');
	      var methodId = web3.eth.abi.encodeFunctionSignature("stake(bytes)");
          var signature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser, mockRetention.address, methodId), ownerSignatureBorderCrossing);
          var beforeAmount = await balance.current(authenticatedUser);
          await mockRetention.stake(signature, { from: authenticatedUser , value: amount});
          var afterAmount = await balance.current(authenticatedUser);
          assert(beforeAmount.gt(afterAmount));
       });
       it('an authorized user can withdraw ethers', async function () {	
	      var methodId = web3.eth.abi.encodeFunctionSignature("withdraw(bytes)");
          var signature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser, mockRetention.address, methodId), ownerSignatureBorderCrossing);
          var beforeAmount = await balance.current(authenticatedUser);
          await mockRetention.withdraw(signature, { from: authenticatedUser});
          var afterAmount = await balance.current(authenticatedUser);
          assert(afterAmount.gt(beforeAmount));
       });
       it('ownerRetention can transfer ownership', async function () {
          await mockRetention.transferOwnership(newOwner, { from: ownerRetention });
     });
   });
   context('in not normal conditions', () => {
     it('an unauthorized user cannot stake ethers', async function () {	
	      const amount = ether('23');
	      var methodId = web3.eth.abi.encodeFunctionSignature("stake(bytes)");
          var signature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser, mockRetention.address, methodId), ownerSignatureBorderCrossing);
          await shouldFail(
              mockRetention.withdraw(signature, { from: anyone})
          );
     });
     it('an unauthorized user cannot withdraw ethers', async function () {	
	      var methodId = web3.eth.abi.encodeFunctionSignature("withdraw(bytes)");
          var signature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser, mockRetention.address, methodId), ownerSignatureBorderCrossing);
          await shouldFail(
              mockRetention.withdraw(signature, { from: anyone})
          );
     });
     it('anyone cannot transfer ownership', async function () {
          await shouldFail(
                mockRetention.transferOwnership(anyone, { from: anyone })
          );
     });
   });
});
