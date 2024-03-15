// Import FungibleToken and YormToken contracts from version 0x05
import FungibleToken from 0x05
import YormToken from 0x05

// Create Yorm Token Vault Transaction
transaction () {

    // Define references
    let userVault: &YormToken.Vault{FungibleToken.Balance, 
        FungibleToken.Provider, 
        FungibleToken.Receiver, 
        YormToken.VaultInterface}?
    let account: AuthAccount

    prepare(acct: AuthAccount) {

        // Borrow the vault capability and set the account reference
        self.userVault = acct.getCapability(/public/Vault)
            .borrow<&YormToken.Vault{FungibleToken.Balance, FungibleToken.Provider, FungibleToken.Receiver, YormToken.VaultInterface}>()
        self.account = acct
    }

    execute {
        if self.userVault == nil {
            // Create and link an empty vault if none exists
            let emptyVault <- YormToken.createEmptyVault()
            self.account.save(<-emptyVault, to: /storage/VaultStorage)
            self.account.link<&YormToken.Vault{FungibleToken.Balance, 
                FungibleToken.Provider, 
                FungibleToken.Receiver, 
                YormToken.VaultInterface}>(/public/Vault, target: /storage/VaultStorage)
            log("Empty vault created and linked")
        } else {
            log("Vault already exists and is properly linked")
        }
    }
}