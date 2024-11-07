#[starknet::interface]
pub trait IRewardSystem<TContractState> {
    // Function to add points to a user's balance
    fn add_points(ref self: TContractState, user: felt252, points: felt252);
    
    // Function to redeem points from a user's balance
    fn redeem_points(ref self: TContractState, user: felt252, points: felt252);
    
    // Function to get the balance of a user
    fn get_balance(self: @TContractState, user: felt252) -> felt252;
}

#[starknet::contract]
mod RewardSystem {
    #[storage]
    struct Storage {
        user_balance: HashMap<felt252, felt252>, // Mapping of user address to their balance
    }

    // Embed the ABI for the contract interface
    #[abi(embed_v0)]
    impl RewardSystemImpl of super::IRewardSystem<ContractState> {
        
        // Function to add points to a user's balance
        fn add_points(ref self: ContractState, user: felt252, points: felt252) {
            // Retrieve current balance
            let current_balance = self.user_balance.read(user);
            // Add points to the current balance
            let new_balance = current_balance + points;
            // Update the balance
            self.user_balance.write(user, new_balance);
            // Emit event for adding points
            PointsAdded.emit(user, points);
        }

        // Function to redeem points from a user's balance
        fn redeem_points(ref self: ContractState, user: felt252, points: felt252) {
            // Retrieve current balance
            let current_balance = self.user_balance.read(user);
            // Ensure user has sufficient balance
            assert(current_balance >= points, 'Insufficient balance');
            // Deduct points from balance
            let new_balance = current_balance - points;
            // Update the balance
            self.user_balance.write(user, new_balance);
            // Emit event for redeeming points
            PointsRedeemed.emit(user, points);
        }

        // Function to retrieve the balance of a user
        fn get_balance(self: @ContractState, user: felt252) -> felt252 {
            // Return current balance
            return self.user_balance.read(user);
        }
    }
    
    // Events for adding and redeeming points
    #[event]
    func PointsAdded(user: felt252, points: felt252);
    
    #[event]
    func PointsRedeemed(user: felt252, points: felt252);
}
