module aptos_asset::fungible_asset {
    //* Importing the necessary modules */ 
    
    // Importing functionalities for fungible assets, including self-reference, minting, transferring, burning, metadata, and fungible asset utilities.
    use aptos_framework::fungible_asset::{Self, MintRef, TransferRef, BurnRef, Metadata, FungibleAsset};

    // Importing object management functionalities, including self-reference and object handling.
    use aptos_framework::object::{Self, Object};

    // Importing the primary fungible store module.
    use aptos_framework::primary_fungible_store;

    // Importing standard error handing functionalities.
    use std::error;

    // Importing functionalities for handling signers.
    use std::signer;

    // Importing functionalities for UTF-8 string manipulation.
    use std::string::utf8;

    // Importing functionalities for handling optional value.
    use std::option; 
    
    // Only fungible asset metadata owner can make changes.
    // Error code indicating that the action is not allowed because the user is not the owner of the fungible asset metadata.
    const ENOT_OWNER: u64 = 1;

    // Symbol for the fungible asset, represented as a vector of bytes.
    const ASSET_SYMBOL: vector<u8> = b"META";

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    // Hold refs to control the minting, transfer, and burning of the fungible assets.
    struct ManagedFungibleAsset has key {
        mint_ref: MintRef, // Reference for minting assets
        transfer_ref: TransferRef, // Reference for transferring assets
        burn_ref: BurnRef, // Reference for burning assets
    }
    
    fun init_module(admin: &signer) {
        // Create a name object for the asset using the admin signer and the asset symbol.
        let contructor_ref = &object::create_named_object(admin, ASSET_SYMBOL);

        // Create the primary store for the fungible asset with the specified metadata.
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            contructor_ref,
            option::none(), // No specific options
            utf8(b"META Coin"), // Name of the asset
            utf8(ASSET_SYMBOL), // Symbol of the asset
            8, // Number of the decimals
            utf8(b"https://drive.google.com/file/d/1vFm-kF6O3onxPgFJ_rVLh9YGFT_fFWM6/view?usp=sharing"), // Icon URL
            utf8(b"http://metaschool.so"), // Project URL 
        );

        // Create mint, burn, and transfer references to allow the creator manage the fungible asset.
        let mint_ref = fungible_asset::generate_mint_ref(contructor_ref);
        let transfer_ref = fungible_asset::generate_transfer_ref(contructor_ref);
        let burn_ref = fungible_asset::generate_burn_ref(contructor_ref);

        // Generate a signer for the metadata object
        let metadata_object_signer = object::generate_signer(contructor_ref);

        // Move the managed fungible asset to the metadata object signer's account
        move_to(
            &metadata_object_signer, 
            ManagedFungibleAsset{ mint_ref, transfer_ref, burn_ref }
        );  // Initialize the managed the fungible asset
    }     
    
    #[view]
    // Return the address of the managed fungible asset that's created when this module is deployed.  
    public fun get_metadata(): Object<Metadata> {
        let asset_address = object::create_object_address(&@aptos_asset, ASSET_SYMBOL);
        object::address_to_object<Metadata>(asset_address);
    }
}