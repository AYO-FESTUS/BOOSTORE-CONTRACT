
#[starknet::interface]
pub trait IBookstore<TContractState>{
    func add_book(ref self: TContractState, book_id: felt, price: felt252, stock: felt252);
    func buy_book(ref self: TContractState, book_id: felt252);
    func lend_book(ref self: TContractState, book_id: felt252);
    func return_book(ref self: TContractState, book_id: felt252);
    func get_book_stock(self: @TContractState, book_id: felt252) -> felt252;
    func get_lent_books(self: @TContractState, book_id: felt252) -> felt252;
}

#[starknet::contract]
pub mod Bookstore {
    #[storage]
    struct Storage {
        books: LegacyMap<felt, (felt252, felt252)>,   // book_id -> (price, stock)
        lent_books: LegacyMap<felt252, felt252>,      // book_id -> number of lent copies
    }

    #[constructor]
    fn constructor(ref self: TContractState) {
        // Initialize an empty bookstore
    }

    #[abi(embed_v0)]
    impl IBookstore of IBookstore {
        // Add a new book to the store
        fn add_book(ref self: ContractState, book_id: felt, price: felt252, stock: felt252) {
            assert stock > 0, 'Stock must be greater than 0';  // Ensure stock is positive
            self.books.write(book_id, (price, stock));
            self.lent_books.write(book_id, 0);  // Initialize lent books to 0
        }

        // Buy a book from the store
        fn buy_book(ref self: TContractState, book_id: felt252) {
            let (price, stock) = self.books.read(book_id);
            assert stock > 0, 'Out of stock';  // Ensure the book is in stock
            self.books.write(book_id, (price, stock - 1));  // Reduce stock by 1
        }

        // Lend a book from the store
        fn lend_book(ref self: TContractState, book_id: felt252) {
            let (price, stock) = self.books.read(book_id);
            assert stock > 0, 'Out of stock';  // Ensure the book is available to lend

            // Reduce stock and increase the lent books count
            self.books.write(book_id, (price, stock - 1));
            let current_lent = self.lent_books.read(book_id);
            self.lent_books.write(book_id, current_lent + 1);
        }

        // Return a lent book to the store
        fn return_book(ref self: TContractState, book_id: felt252) {
            let (price, stock) = self.books.read(book_id);
            let current_lent = self.lent_books.read(book_id);
            assert current_lent > 0, 'No lent books to return';  // Ensure there are lent books to return

            // Increase stock and reduce the lent books count
            self.books.write(book_id, (price, stock + 1));
            self.lent_books.write(book_id, current_lent - 1);
        }

        // Get the current stock of a book
        fn get_book_stock(self: @TContractState, book_id: felt252) -> felt252 {
            let (_, stock) = self.books.read(book_id);
            stock
        }

        // Get the current number of lent books
        fn get_lent_books(self: @TContractState, book_id: felt252) -> felt252 {
            let current_lent = self.lent_books.read(book_id);
            current_lent
        }
    }
}


