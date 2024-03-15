import FungibleToken from 0x05
import YormToken from 0x05

transaction(receiver: Address, amount: UFix64) {

    prepare(signer: AuthAccount) {
        // Borrow the YormToken Minter reference
        let minter = signer.borrow<&YormToken.Minter>(from: /storage/MinterStorage)
            ?? panic("You are not the YormToken minter")
        
        // Borrow the receiver's YormToken Vault capability
        let receiverVault = getAccount(receiver)
            .getCapability<&YormToken.Vault{FungibleToken.Receiver}>(/public/Vault)
            .borrow()
            ?? panic("Error: Check your YormToken Vault status")
        
        // Minted tokens reference
        let mintedTokens <- minter.mintToken(amount: amount)

        // Deposit minted tokens into the receiver's YormToken Vault
        receiverVault.deposit(from: <-mintedTokens)
    }

    execute {
        log("YormToken minted and deposited successfully")
        log("Tokens minted and deposited: ".concat(amount.toString()))
    }
}