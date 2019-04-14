const Milestone = require('Embark/contracts/Milestone');

// Parameters
const reserveRatio = 142857;  // Kappa (~ 6)
const theta = 350000;         // 35% in ppm
const p0 =  1;                // Price of internal token in external tokens.
const initialRaise = 300000;  // Raise amount in external tokens.
const friction = 20000;       // 2% in ppm
const gasPrice = 15000000000; // 15 gwei
const duration = 3024000000000000; // ~5 weeks.
const minExternalContibution = 100000;

let owner = "0xFE5481d521Cf54306dba9043b4aeFe65f2A8c89B";
let accounts;

// For documentation please see https://embark.status.im/docs/contracts_testing.html
config({
  deployment: {
    accounts: [{
      mnemonic: "dismiss fee squeeze symbol already forest rent sphere crack crane smile hurdle"
    }]
  },
  contracts: {
    CommonsToken: {
      args: ['$ERC20', reserveRatio, gasPrice, theta, p0, initialRaise, '$FundingPoolMock', friction, duration, minExternalContibution]
    },
    ConvictionVoting: {
      track: false,
      args: ['$CommonsToken']
    },
    BondingCurve: {
      deploy: false
    },
    ERC20Mintable: {
      args: [owner]
    },
    ERC20: {},
    FundingPoolMock: {},
    MinterRole: {
      args: [owner]
    },
    Commons: {
      deploy: false
    },
    ERC20BondingToken: {
      deploy: false
    },
    Milestone: {
      track: false,
      args: [owner, 10]
    }
  }
}, (_err, web3_accounts) => {
  accounts = web3_accounts
});

contract("Milestone", function () {
  this.timeout(0);

  describe('Setup', function () {
    it("should set values in constructor", async function () {
      let mm = await Milestone.methods.milestoneManager().call();
      assert.strictEqual(mm, owner);
      let reviewer = await Milestone.methods.reviewer().call();
      assert.strictEqual(reviewer, owner);
      let receiver = await Milestone.methods.receiver().call();
      assert.strictEqual(receiver, owner);
    });

    it("should be unfunded", async function() {
      let funded = await Milestone.methods.isFunded().call();
      assert.equal(funded, false);
    });

    it("should be unfinished", async function() {
      let done = await Milestone.methods.done().call();
      assert.equal(done, false);
    });

    it("should be unfinished", async function() {
      let done = await Milestone.methods.done().call();
      assert.equal(done, false);
    });

    it("should be unreviewed", async function() {
      let reviewed = await Milestone.methods.reviewed().call();
      assert.equal(reviewed, false);
    });


  });

  /*
  it("set storage value", async function () {
    await SimpleStorage.methods.set(150).send();
    let result = await SimpleStorage.methods.get().call();
    assert.strictEqual(parseInt(result, 10), 150);
  });

  it("should have account with balance", async function() {
    let balance = await web3.eth.getBalance(accounts[0]);
    assert.ok(parseInt(balance, 10) > 0);
  });
  */
});

