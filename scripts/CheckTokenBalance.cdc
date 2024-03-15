import FungibleToken from 0x05
import YormToken from 0x05

pub fun main(account: Address) {

    // Attempt to borrow PublicVault capability
    let publicVault: &YormToken.Vault{FungibleToken.Balance, 
    FungibleToken.Receiver, YormToken.VaultInterface}? =
        getAccount(account).getCapability(/public/Vault)
            .borrow<&YormToken.Vault{FungibleToken.Balance, 
            FungibleToken.Receiver, YormToken.VaultInterface}>()

    if (publicVault == nil) {
        // Create and link an empty vault if capability is not present
        let newVault <- YormToken.createEmptyVault()
        getAuthAccount(account).save(<-newVault, to: /storage/VaultStorage)
        getAuthAccount(account).link<&YormToken.Vault{FungibleToken.Balance, 
        FungibleToken.Receiver, YormToken.VaultInterface}>(
            /public/Vault,
            target: /storage/VaultStorage
        )
        log("Empty vault created and linked")
        
        // Borrow the vault capability again to display its balance
        let retrievedVault: &YormToken.Vault{FungibleToken.Balance}? =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&YormToken.Vault{FungibleToken.Balance}>()
        log("Balance of the new vault: ")
        log(retrievedVault?.balance)
    } else {
        log("Vault already exists and is properly linked")
        
        // Borrow the vault capability for further checks
        let checkVault: &YormToken.Vault{FungibleToken.Balance, 
        FungibleToken.Receiver, YormToken.VaultInterface} =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&YormToken.Vault{FungibleToken.Balance, 
                FungibleToken.Receiver, YormToken.VaultInterface}>()
                ?? panic("Vault capability not found")
        
        // Check if the vault's UUID is in the list of vaults
        if YormToken.vaults.contains(checkVault.uuid) {     
            log("Balance of the existing vault:")       
            log(publicVault?.balance)
            log("This is a YormToken vault")
        } else {
            log("This is not a YormToken vault")
        }
    }
}
