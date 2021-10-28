// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";

contract Library is Ownable {
    uint8 private constant NOT_BORROWED = 0;
    uint8 private constant BORROWED = 1;
    uint8 private constant RETURNED = 2;

    struct Book {
        string name;
        uint32 copies;
        mapping(address => uint8) borrowersStatuses;
        address[] borrowers;
    }
    Book[] private books;

    struct AvailableBook {
        uint id;
        string name;
    }
    function getAvailableBooks() external view returns(AvailableBook[] memory) {
        // oof, have to loop trough the array 2 times because solidity doesn't support resizable arrays in memory
        // TODO find a better way
        uint availableCount = 0;
        for (uint i = 0; i < books.length; i++) {
            if (books[i].copies > 0) {
                availableCount++;
            }
        }

        AvailableBook[] memory result = new AvailableBook[](availableCount);
        uint j = 0;
        for (uint id = 0; id < books.length; id++) {
            if (books[id].copies > 0) {
                result[j++] = AvailableBook(id, books[id].name);
            }
        }

        return result;
    }

    function addBook(string calldata name, uint32 copies) external onlyOwner returns (uint bookId) {
        Book storage book = books.push();
        book.name = name;
        book.copies = copies;
        return books.length - 1;
    }

    function borrowBook(uint bookId) external {
        Book storage book = books[bookId];
        require(book.copies > 0, "No copies left in the library");
        require(book.borrowersStatuses[msg.sender] != BORROWED, "Book already borrowed by this user");

        if (book.borrowersStatuses[msg.sender] == NOT_BORROWED) {
            book.borrowers.push(msg.sender);
        }
        book.borrowersStatuses[msg.sender] = BORROWED;
        book.copies--;
    }

    function returnBook(uint bookId) external {
        Book storage book = books[bookId];
        require(book.borrowersStatuses[msg.sender] == BORROWED, "Book not borrowed");
        book.borrowersStatuses[msg.sender] = RETURNED;
        book.copies++;
    }

    function getBookHistoricalBorrowers(uint bookId) external view returns(address[] memory) {
        return books[bookId].borrowers;
    }
}
