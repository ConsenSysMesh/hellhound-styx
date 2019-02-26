
const zos = require('zos-lib')

const BigNumber = web3.BigNumber;
const ArbitrableMock = artifacts.require('SampleArbitrable');
const { BN, expectEvent, shouldFail, ether, balance } = require('openzeppelin-test-helpers');


contract('SampleArbitrable', function (accounts) {

    let mockArbitrable;
  
    let amountFees = ether('30');

    const [
        owner,
        newOwner,
        trustedThirdParty,
        trustedThirdParty2,
        mediator1,
        mediator2,
        anyone
    ] = accounts;

    before(async function () {
        mockArbitrable = await ArbitrableMock.new(trustedThirdParty, amountFees,  { from: owner });
    });
  
    context('in normal conditions', () => {
        it('owner cannot add mediators ', async function () {	
	        await shouldFail(
	            mockArbitrable.addMediators([mediator1, mediator2],{ from : owner})
	        );
        });
        it('anyone cannot add mediators ', async function () {	
	        await shouldFail(
	            mockArbitrable.addMediators([mediator1, mediator2],{ from : anyone})
	        );
        });
        it('trustedThirdParty can add mediators', async function () {	
	        const { logs } = await mockArbitrable.addMediators([mediator1, mediator2],{ from : trustedThirdParty});
	        expectEvent.inLogs(logs, 'LogMediatorsAdded');
        });
        it('trustedThirdParty cannot add mediators twice', async function () {	
	        await shouldFail(
	            mockArbitrable.addMediators([mediator1, mediator2],{ from : trustedThirdParty})
	        );
        });
        it('trustedThirdParty can add trusted Third Party', async function () {	
	        const { logs } = await mockArbitrable.addTrustedThirdParty(trustedThirdParty2,{ from : trustedThirdParty});
	        expectEvent.inLogs(logs, 'LogTrustedThirdPartyAdded');
        });
        it('can get number of mediators ', async function () {	
	        const nbMediators = await mockArbitrable.getNbMediators({ from : anyone});
	        assert(nbMediators.eq(new BN('2')));
        });
        it('anyone cannot start arbitration', async function () {	
            await shouldFail(
	            mockArbitrable.startArbitration({ from : anyone, value : amountFees})
	        );
        });
        it('owner can start arbitration when there is mediators', async function () {	
            assert((await balance.current(mockArbitrable.address)).eq(ether('0')));
	        const { logs } = await mockArbitrable.startArbitration({ from : owner, value : amountFees});
            expectEvent.inLogs(logs, 'LogArbitrationStarted');
            assert((await balance.current(mockArbitrable.address)).eq(amountFees));
        });
        it('owner cannot start arbitration twice', async function () {	
            await shouldFail(
                mockArbitrable.startArbitration({ from : owner, value : amountFees})
            );
        });
        it('anyone cannot accept', async function () {	
            await shouldFail(
                mockArbitrable.accept({ from : anyone})
            );
        });
        it('owner cannot accept', async function () {	
            await shouldFail(
                mockArbitrable.accept({ from : owner})
            );
        });
        it('trustedThirdParty cannot accept', async function () {	
            await shouldFail(
                mockArbitrable.accept({ from : trustedThirdParty})
            );
        });
        it('mediator can accept', async function () {	
            var beforeMediatorAmount = await balance.current(mediator1);
            const { logs } = await mockArbitrable.accept({ from : mediator1});
            expectEvent.inLogs(logs, 'LogMediatorVoted', {
                mediatorAddress : mediator1
            });
            var afterMediatorAmount = await balance.current(mediator1);
            var afterContractAmount = await balance.current(mockArbitrable.address);
            assert(afterMediatorAmount.gt(beforeMediatorAmount));
            assert(afterContractAmount.eq(ether('15')));
        });
        it('mediator cannot accept twice', async function () {	
            await shouldFail(
                 mockArbitrable.accept({ from : mediator1})
            );
        });
        it('mediator cannot accept and then refuse', async function () {	
            await shouldFail(
                 mockArbitrable.refuse({ from : mediator1})
            );
        });
        it('anyone cannot refuse', async function () {	
            await shouldFail(
                mockArbitrable.refuse({ from : anyone})
            );
        });
        it('owner cannot refuse', async function () {	
            await shouldFail(
                mockArbitrable.refuse({ from : owner})
            );
        });
        it('trustedThirdParty cannot refuse', async function () {	
            await shouldFail(
                mockArbitrable.refuse({ from : trustedThirdParty})
            );
        });
        it('mediator can refuse', async function () {	
            var beforeMediatorAmount = await balance.current(mediator2);
            const { logs } = await mockArbitrable.refuse({ from : mediator2});
            expectEvent.inLogs(logs, 'LogMediatorVoted', {
                mediatorAddress : mediator2
            });
            var afterMediatorAmount = await balance.current(mediator2);
            var afterContractAmount = await balance.current(mockArbitrable.address);
            assert(afterMediatorAmount.gt(beforeMediatorAmount));
            assert(afterContractAmount.eq(ether('0')));
        });
        it('mediator cannot refuse and then accept', async function () {	
            await shouldFail(
                 mockArbitrable.accept({ from : mediator2})
            );
        });
        it('mediator cannot refuse twice', async function () {	
            await shouldFail(
                 mockArbitrable.refuse({ from : mediator2})
            );
        });
    });
});
