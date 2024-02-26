/// Example of an unlimited "Sui NFT" collection - anyone is free to
/// mint their NFT. Shows how to initialize the `Publisher` and how
/// to use it to get the `Display<NFT>` object - a way to describe a
/// type for the ecosystem.
module nft::NFT {
    use sui::tx_context::{sender, TxContext};
    use std::string::{utf8, String};
    use sui::transfer;
    use sui::object::{Self, UID};

    // The creator bundle: these two packages often go together.
    use sui::package;
    use sui::display;

    /// The NFT - an outstanding collection of digital art.
    struct NFT has key, store {
        id: UID,
        name: String,
        img_url: String,
        description: String,
    }

    /// One-Time-Witness for the module.
    struct NFT has drop {}

    /// In the module initializer we claim the `Publisher` object
    /// to then create a `Display`. The `Display` is initialized with
    /// a set of fields (but can be modified later) and published via
    /// the `update_version` call.
    ///
    /// Keys and values are set in the initializer but could also be
    /// set after publishing if a `Publisher` object was created.
    fun init(otw: NFT, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"image_url"),
            utf8(b"description"),    
        ];

        let values = vector[
            // For `name` we can use the `NFT.name` property
            utf8(b"{name}"),
            // For `image_url` we use an IPFS template + `img_url` property.
            utf8(b"ipfs://{img_url}"),
            // Description for `NFT` objects.
            utf8(b"{description}"),
          
        ];

        // Claim the `Publisher` for the package!
        let publisher = package::claim(otw, ctx);

        // Get a new `Display` object for the `NFT` type.
        let display = display::new_with_fields<NFT>(
            &publisher, keys, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display);

        transfer::public_transfer(publisher, sender(ctx));
        transfer::public_transfer(display, sender(ctx));
    }

    /// Anyone can mint their `NFT`!
     entry fun mint(name: String, img_url: String, description: String, ctx: &mut TxContext){
        let id = object::new(ctx);
        let hero = NFT { id, name, img_url, description };
        transfer::public_transfer(hero, sender(ctx));
    }

    /// Permanently delete `nft`
     entry fun burn(nft: NFT, _: &mut TxContext) {
        let NFT { id, name, img_url, description } = nft;
        object::delete(id)
    }

    


}
