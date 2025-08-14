module MyModule::LocalDealsMarketplace {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::string::{String};

    /// Struct representing a local deal listing
    struct Deal has store, key {
        business_name: String,     // Name of the business offering the deal
        deal_description: String,  // Description of the deal
        price: u64,               // Price in APT tokens
        is_active: bool,          // Whether the deal is still available
        total_purchases: u64,     // Number of times this deal was purchased
    }

    /// Function to create a new deal listing
    public fun create_deal(
        business_owner: &signer, 
        business_name: String, 
        deal_description: String, 
        price: u64
    ) {
        let deal = Deal {
            business_name,
            deal_description,
            price,
            is_active: true,
            total_purchases: 0,
        };
        move_to(business_owner, deal);
    }

    /// Function for customers to purchase a deal
    public fun purchase_deal(
        customer: &signer, 
        business_owner: address, 
        payment_amount: u64
    ) acquires Deal {
        let deal = borrow_global_mut<Deal>(business_owner);
        
        // Check if deal is active and payment matches price
        assert!(deal.is_active, 1);
        assert!(payment_amount >= deal.price, 2);
        
        // Transfer payment from customer to business owner
        let payment = coin::withdraw<AptosCoin>(customer, payment_amount);
        coin::deposit<AptosCoin>(business_owner, payment);
        
        // Update deal statistics
        deal.total_purchases = deal.total_purchases + 1;
        
        // Optionally deactivate deal after certain purchases
        if (deal.total_purchases >= 100) {
            deal.is_active = false;
        };
    }
}