
const zos = require('zos-lib')

const BigNumber = web3.BigNumber;
const PermissionsVerifierMock = artifacts.require('PermissionsVerifier');
const shouldFail = require('../../node_modules/openzeppelin-solidity/test/helpers/shouldFail');
const expectEvent = require('../../node_modules/openzeppelin-solidity/test/helpers/expectEvent');

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
.should();

contract('PermissionsVerifier', function (accounts) {

  let mockPermissionsVerifier;

  const [
    owner,
    newOwner,
    authenticatedUser,
    anyone
  ] = accounts;

  before(async function () {
    // create proxy retention contract
    mockPermissionsVerifier = await PermissionsVerifierMock.new({ from: owner });
  });
  
  context('in normal conditions', () => {
       it('can detect authenticated user', async function () {	
	      var signature = await web3.eth.sign(web3.utils.soliditySha3(mockPermissionsVerifier.address, authenticatedUser), owner);
		  var isAuthenticatedUser = await mockPermissionsVerifier.isAuthorized(authenticatedUser, signature);
          isAuthenticatedUser.should.equal(true);
       });
       it('can detect valid signature when calling isAuthorizedToCallContract', async function () {
	      var sampleContractAddress = web3.utils.randomHex(20);   
          var invalidSignature = await web3.eth.sign(web3.utils.soliditySha3(mockPermissionsVerifier.address, authenticatedUser, sampleContractAddress), owner);
          var isAuthenticatedUser = await mockPermissionsVerifier.isAuthorizedToCallContract(authenticatedUser, sampleContractAddress, invalidSignature);
          isAuthenticatedUser.should.equal(true);
       });
	   it('can detect valid signature when calling isAuthorizedToCallContractAndMethod', async function () {
	      var sampleContractAddress = web3.utils.randomHex(20);   
	      var methodId = web3.utils.randomHex(4);   
          var invalidSignature = await web3.eth.sign(web3.utils.soliditySha3(mockPermissionsVerifier.address, authenticatedUser, sampleContractAddress, methodId), owner);
          var isAuthenticatedUser = await mockPermissionsVerifier.isAuthorizedToCallContractAndMethod(authenticatedUser, sampleContractAddress, methodId, invalidSignature);
          isAuthenticatedUser.should.equal(true);
       });
   });
   context('in not normal conditions', () => {
     it('can detect invalid signature when calling isAuthorized (invalid signer)', async function () {
       var invalidSignature = await web3.eth.sign(web3.utils.soliditySha3(mockPermissionsVerifier.address, authenticatedUser), anyone);
       var isAuthenticatedUser = await mockPermissionsVerifier.isAuthorized(authenticatedUser, invalidSignature);
       isAuthenticatedUser.should.equal(false);
     });
	 it('can detect invalid signature when calling isAuthorizedToCallContract (invalid signer)', async function () {
	   var sampleContractAddress = web3.utils.randomHex(20);   
       var invalidSignature = await web3.eth.sign(web3.utils.soliditySha3(mockPermissionsVerifier.address, authenticatedUser, sampleContractAddress), anyone);
       var isAuthenticatedUser = await mockPermissionsVerifier.isAuthorizedToCallContract(authenticatedUser, sampleContractAddress, invalidSignature);
       isAuthenticatedUser.should.equal(false);
     });
	 it('can detect invalid signature when calling isAuthorizedToCallContractAndMethod (invalid signer)', async function () {
	   var sampleContractAddress = web3.utils.randomHex(20);   
	   var methodId = web3.utils.randomHex(4);   
       var invalidSignature = await web3.eth.sign(web3.utils.soliditySha3(mockPermissionsVerifier.address, authenticatedUser, sampleContractAddress, methodId), anyone);
       var isAuthenticatedUser = await mockPermissionsVerifier.isAuthorizedToCallContractAndMethod(authenticatedUser, sampleContractAddress, methodId, invalidSignature);
       isAuthenticatedUser.should.equal(false);
     });
	 it('can detect invalid signature when calling isAuthorizedToCallContract (invalid contract destination)', async function () {
	   var sampleContractAddress = web3.utils.randomHex(20);  
       var sampleContractAddress2 = web3.utils.randomHex(20);  	   
       var invalidSignature = await web3.eth.sign(web3.utils.soliditySha3(mockPermissionsVerifier.address, authenticatedUser, sampleContractAddress), owner);
       var isAuthenticatedUser = await mockPermissionsVerifier.isAuthorizedToCallContract(authenticatedUser, sampleContractAddress2, invalidSignature);
       isAuthenticatedUser.should.equal(false);
     });
	 it('can detect invalid signature when calling isAuthorizedToCallContractAndMethod (invalid mehtod id)', async function () {
	   var sampleContractAddress = web3.utils.randomHex(20);   
	   var methodId = web3.utils.randomHex(4);   
	   var methodId2 = web3.utils.randomHex(4);   
       var invalidSignature = await web3.eth.sign(web3.utils.soliditySha3(mockPermissionsVerifier.address, authenticatedUser, sampleContractAddress, methodId), owner);
       var isAuthenticatedUser = await mockPermissionsVerifier.isAuthorizedToCallContractAndMethod(authenticatedUser, sampleContractAddress, methodId2, invalidSignature);
       isAuthenticatedUser.should.equal(false);
     });
     it('anyone cannot transfer ownership', async function () {
          await shouldFail(
                mockPermissionsVerifier.transferOwnership(anyone, { from: anyone })
          );
     });
   });
});
