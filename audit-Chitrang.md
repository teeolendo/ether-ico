The following is a micro audit of git commit 5bfe1663b9c88504e4a3b1e92440e9fc85cddadb by Chitrang.

## General comments

- Overall Great Implementation
- You can also add an implementation for Redeem()

## issue-1

[High] Require Validation. Not having enough balance

SpaceICO.sol:117 Validate whether the amount requested to transfer is available or not?
On Line 102, is transfer() a recursive function call or we calling the transfer() in SpaceToken file. Don’t we have need inheritance. Is SpaceToken acting as a library ?
