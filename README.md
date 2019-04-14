# Testing individual functions

1. Add funds to the ConvictionVoting

```
web3.eth.sendTransaction({ value: "1000000000", to: ConvictionVoting.address})
```

2. Propose milestone to ConvictionVoting

```
Milestone.methods.proposeToCommons(ConvictionVoting.address).send().then(console.log)
```

3. Verify milestone is registered as proposal

```
await ConvictionVoting.methods.getProposal(1).call()
```

4. Make the proposal pass

```
ConvictionVoting.methods.fakeProposalPass(1).send().then(console.log)
```

5. Verify that milestone is now funded

```
await Milestone.methods.isFunded().call()
```

6. Mark milestone done

```
Milestone.methods.markAsDone(true).send().then(console.log)
```

7. Review milestone work positively

```
Milestone.methods.approve().send().then(console.log)
```

8. Request payout

```
Milestone.methods.payout().send().then(console.log)
```

