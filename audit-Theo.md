https://github.com/teeolendo/ether-ico

The following is a micro audit of git commit c7db589003477572344feba6943ea46e95aa5a4b by Theo.

## General comments

- 


## issue-1

**[High]** Redeem() calculates the number of tokens incorrectly.
Since the _investors array stores the amount contributed in wei, all that is neccessary here is to multiply the number by SPC_TO_ETH_RATIO. 

## issue-2

**[Medium]** line #105 in SpaceICO.sol multiplys the result of a division

## issue-3

**[Low]** advancePhase() should take an argument. The function could accidentally get called twice and it would skip over a phase irreversably and nothing would prevent this.


## Nitpicks

- allowList() should allow arrays of addresses to be inputted for eficiency 

- line #16 in SpaceToken.sol should be a constant and renamed in all caps to conform to style standards

- SpaceToken.sol: setTax(), taxStatus(), treasury() should be external

- SpaceICO.sol: icoPhase(), should be external

- lines # 17-22 in SpaceICO.sol should be constant varibles

- _ICO_TARGET is an unused variable, delete to save on gas

- I would add a treasury contract which holds the tokens
