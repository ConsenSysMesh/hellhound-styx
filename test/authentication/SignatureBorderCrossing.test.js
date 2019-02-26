
const zos = require('zos-lib')

const BigNumber = web3.BigNumber;
const SignatureBorderCrossingMock = artifacts.require('SignatureBorderCrossing');
const { expectEvent, shouldFail } = require('openzeppelin-test-helpers');

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
.should();

contract('SignatureBorderCrossing', function (accounts) {

  let mockSignatureBorderCrossing;

  const [
    owner,
    newOwner,
    authenticatedUser,
    anyone
  ] = accounts;

  before(async function () {
    mockSignatureBorderCrossing = await SignatureBorderCrossingMock.new({ from: owner });
  });
  
  context('in normal conditions', () => {
       it('can detect authenticated user', async function () {	
	      var signature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser), owner);
		  var isAuthenticatedUser = await mockSignatureBorderCrossing.isAuthorized(authenticatedUser, signature);
          isAuthenticatedUser.should.equal(true);
       });
       it('can detect valid signature when calling isAuthorizedToCallContract', async function () {
	      var sampleContractAddress = web3.utils.randomHex(20);   
          var signature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser, sampleContractAddress), owner);
          var isAuthenticatedUser = await mockSignatureBorderCrossing.isAuthorizedToCallContract(authenticatedUser, sampleContractAddress, signature);
          isAuthenticatedUser.should.equal(true);
       });
	   it('can detect valid signature when calling isAuthorizedToCallContractAndMethod', async function () {
	      var sampleContractAddress = web3.utils.randomHex(20);   
	      var methodId = web3.utils.randomHex(4);   
          var signature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser, sampleContractAddress, methodId), owner);
          var isAuthenticatedUser = await mockSignatureBorderCrossing.isAuthorizedToCallContractAndMethod(authenticatedUser, sampleContractAddress, methodId, signature);
          isAuthenticatedUser.should.equal(true);
       });
   });
   context('in not normal conditions', () => {
     it('can detect invalid signature when calling isAuthorized (invalid signer)', async function () {
       var invalidSignature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser), anyone);
       var isAuthenticatedUser = await mockSignatureBorderCrossing.isAuthorized(authenticatedUser, invalidSignature);
       isAuthenticatedUser.should.equal(false);
     });
	 it('can detect invalid signature when calling isAuthorizedToCallContract (invalid signer)', async function () {
	   var sampleContractAddress = web3.utils.randomHex(20);   
       var invalidSignature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser, sampleContractAddress), anyone);
       var isAuthenticatedUser = await mockSignatureBorderCrossing.isAuthorizedToCallContract(authenticatedUser, sampleContractAddress, invalidSignature);
       isAuthenticatedUser.should.equal(false);
     });
	 it('can detect invalid signature when calling isAuthorizedToCallContractAndMethod (invalid signer)', async function () {
	   var sampleContractAddress = web3.utils.randomHex(20);   
	   var methodId = web3.utils.randomHex(4);   
       var invalidSignature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser, sampleContractAddress, methodId), anyone);
       var isAuthenticatedUser = await mockSignatureBorderCrossing.isAuthorizedToCallContractAndMethod(authenticatedUser, sampleContractAddress, methodId, invalidSignature);
       isAuthenticatedUser.should.equal(false);
     });
	 it('can detect invalid signature when calling isAuthorizedToCallContract (invalid contract destination)', async function () {
	   var sampleContractAddress = web3.utils.randomHex(20);  
       var sampleContractAddress2 = web3.utils.randomHex(20);  	   
       var invalidSignature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser, sampleContractAddress), owner);
       var isAuthenticatedUser = await mockSignatureBorderCrossing.isAuthorizedToCallContract(authenticatedUser, sampleContractAddress2, invalidSignature);
       isAuthenticatedUser.should.equal(false);
     });
	 it('can detect invalid signature when calling isAuthorizedToCallContractAndMethod (invalid mehtod id)', async function () {
	   var sampleContractAddress = web3.utils.randomHex(20);   
	   var methodId = web3.utils.randomHex(4);   
	   var methodId2 = web3.utils.randomHex(4);   
       var invalidSignature = await web3.eth.sign(web3.utils.soliditySha3(mockSignatureBorderCrossing.address, authenticatedUser, sampleContractAddress, methodId), owner);
       var isAuthenticatedUser = await mockSignatureBorderCrossing.isAuthorizedToCallContractAndMethod(authenticatedUser, sampleContractAddress, methodId2, invalidSignature);
       isAuthenticatedUser.should.equal(false);
     });
     it('anyone cannot transfer ownership', async function () {
          await shouldFail(
                mockSignatureBorderCrossing.transferOwnership(anyone, { from: anyone })
          );
     });
   });
});
