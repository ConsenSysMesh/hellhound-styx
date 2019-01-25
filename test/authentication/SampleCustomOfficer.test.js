
const zos = require('zos-lib')

const BigNumber = web3.BigNumber;
const SampleCustomOfficerMock = artifacts.require('SampleCustomOfficer');
const SignatureBorderCrossingMock = artifacts.require('SignatureBorderCrossing');
const { expectEvent, shouldFail } = require('openzeppelin-test-helpers');

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
.should();

contract('SampleCustomOfficer', function (accounts) {

  let mockCustomOfficer, mockSignatureBorderCrossing;

  const [
    ownerCustomOfficer,
    ownerSignatureBorderCrossing,
	newOwner,
    authenticatedUser,
    anyone
  ] = accounts;

  before(async function () {
	mockSignatureBorderCrossing = await SignatureBorderCrossingMock.new({ from: ownerSignatureBorderCrossing });
    mockCustomOfficer = await SampleCustomOfficerMock.new(mockSignatureBorderCrossing.address, { from: ownerCustomOfficer });
  });
  
  context('in normal conditions', () => {
       it('can detect authenticated user', async function () {	
	      var signature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser), ownerSignatureBorderCrossing);
		  await mockCustomOfficer.checkUserAddress(signature, { from: authenticatedUser });
       });
       it('can detect valid signature when calling isAuthorizedToCallContract', async function () {
          var signature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser, mockCustomOfficer.address), ownerSignatureBorderCrossing);
          await mockCustomOfficer.checkUserAndContractAddresses(signature, { from: authenticatedUser });
       });
	   it('can detect valid signature when calling isAuthorizedToCallContractAndMethod', async function () {
	      var methodId = web3.eth.abi.encodeFunctionSignature("checkUserAndContractAddressesAndMethodId(bytes)");
          var signature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser, mockCustomOfficer.address, methodId), ownerSignatureBorderCrossing);
          await mockCustomOfficer.checkUserAndContractAddressesAndMethodId(signature, { from: authenticatedUser });
       });
   });
   context('in not normal conditions', () => {
     it('can detect invalid signature when calling isAuthorized (invalid signer)', async function () {
        var signature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser), anyone);
        await shouldFail(
            mockCustomOfficer.checkUserAddress(signature, { from: authenticatedUser })
        );
     });
	 it('can detect invalid signature when calling isAuthorizedToCallContract (invalid signer)', async function () {
	   var signature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser, mockCustomOfficer.address), anyone);
	   await shouldFail(
	       mockCustomOfficer.checkUserAndContractAddresses(signature, { from: authenticatedUser })
	   );
     });
	 it('can detect invalid signature when calling isAuthorizedToCallContractAndMethod (invalid signer)', async function () {
	   var methodId = web3.eth.abi.encodeFunctionSignature("checkUserAndContractAddressesAndMethodId(bytes)");
       var signature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser, mockCustomOfficer.address, methodId), anyone);
	   await shouldFail(
	       mockCustomOfficer.checkUserAndContractAddressesAndMethodId(signature, { from: authenticatedUser })
	   );
     });
	 it('can detect invalid signature when calling isAuthorizedToCallContract (invalid contract destination)', async function () {
	   var sampleContractAddress = web3.utils.randomHex(20);  
       var signature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser, sampleContractAddress), ownerSignatureBorderCrossing);
	   await shouldFail(
	       mockCustomOfficer.checkUserAndContractAddresses(signature, { from: authenticatedUser })
	   );
     });
	 it('can detect invalid signature when calling isAuthorizedToCallContractAndMethod (invalid mehtod id)', async function () {
	   var methodId = web3.utils.randomHex(4);   
	   var signature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser, mockCustomOfficer.address, methodId), ownerSignatureBorderCrossing);
	   await shouldFail(
	       mockCustomOfficer.checkUserAndContractAddressesAndMethodId(signature, { from: authenticatedUser })
	   );
     });
   });
});
