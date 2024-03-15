// Import required token contracts
import FungibleToken from 0x05
import FlowToken from 0x05
import YormToken from 0x05

// SwapToken contract: Facilitates token swapping between YormToken and FlowToken
pub contract SwapToken {

    // Store the last swap timestamp for the contract
    pub var lastSwapTimestamp: UFix64
    
    // Store the last swap timestamp for each user
    pub var userLastSwapTimestamps: {Address: UFix64}

    // Function to swap tokens between YormToken and FlowToken
    pub fun swapTokens(signer: AuthAccount, swapAmount: UFix64) {

        // Borrow YormToken and FlowToken vaults from the signer's storage
        let yormTokenVault = signer.borrow<&YormToken.Vault>(from: /storage/VaultStorage)
            ?? panic("Could not borrow YormToken Vault from signer")

        let flowVault = signer.borrow<&FlowToken.Vault>(from: /storage/FlowVault)
            ?? panic("Could not borrow FlowToken Vault from signer")  

        // Borrow the Minter capability from YormToken
        let minterRef = signer.getCapability<&YormToken.Minter>(/public/Minter).borrow()
            ?? panic("Could not borrow a reference to YormToken Minter")

        // Borrow the FlowToken vault capability for receiving tokens
        let autherVault = signer.getCapability<&FlowToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, FungibleToken.Provider}>(/public/FlowVault).borrow()
            ?? panic("Could not borrow a reference to FlowToken Vault")  

        // Withdraw tokens from FlowVault and deposit them into autherVault
        let withdrawnAmount <- flowVault.withdraw(amount: swapAmount)
        autherVault.deposit(from: <-withdrawnAmount)
        
        // Get the signer's address and the current timestamp
        let userAddress = signer.address
        self.lastSwapTimestamp = self.userLastSwapTimestamps[userAddress] ?? 1.0
        let currentTime = getCurrentBlock().timestamp

        // Calculate the time since the last swap and the minted token amount
        let timeSinceLastSwap = currentTime - self.lastSwapTimestamp
        let mintedAmount = 2.0 * UFix64(timeSinceLastSwap)

        // Mint new YormTokens and deposit them into the vault
        let newYormTokenVault <- minterRef.mintToken(amount: mintedAmount)
        yormTokenVault.deposit(from: <-newYormTokenVault)

        // Update the user's last swap timestamp
        self.userLastSwapTimestamps[userAddress] = currentTime
    }

    // Initialize the contract
    init() {
        // Set default values for the last swap timestamp
        self.lastSwapTimestamp = 1.0
        self.userLastSwapTimestamps = {0x05: 1.0} // Initialize with a default user and timestamp
    }
}