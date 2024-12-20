# E-Wallet Application

## Overview
The E-Wallet Application is a digital wallet app designed to securely store debit and credit cards. The app provides a streamlined user experience and ensures robust security for managing payment card information. The application uses card tokens instead of traditional database IDs (such as MongoDB's ObjectId) for managing cards in the database, enhancing security and privacy.

## Features
- **Card Management**: Add, view, edit, and delete debit/credit cards securely.
- **Secure Tokenization**: Card information is managed using tokens, ensuring user data security.
- **Database Integration**: Efficient database structure for handling tokenized card data.
- **User-Friendly Interface**: Simplified and intuitive UI/UX for seamless navigation and management.
- **QR Code Payment**: Generate payment QR codes to request or receive money.
- **Real-Time Balance Updates**: Displays the current balance for users.
- **Responsive Frontend**: Built with Flutter for a cross-platform mobile experience.
- **API Testing**: APIs were tested and verified using Postman, with test cases available in the `tests` folder.
- **Trader Frontend Webpage**: A React-based frontend webpage for traders to view balances and generate QR codes using backend services.

## Tech Stack
- **Frontend**: Flutter (mobile), React (trader webpage)
- **Backend**: Node.js
- **Database**: MongoDB
- **API Base URL**: `127.0.0.1:3000`
- **Repository**: [E-Wallet GitHub Repository](https://github.com/halimo22/digital-wallet)
- **Security**: Card tokenization for enhanced data protection

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/halimo22/digital-wallet.git
   ```
2. Navigate to the project directory:
   ```bash
   cd e-wallet
   ```
3. Install dependencies:
   ```bash
   npm install
   ```
4. Start the application:
   ```bash
   npm start
   ```

## API Endpoints
### Card Management
- **Add Card**
  - **Endpoint**: `/api/cards`
  - **Method**: POST
  - **Description**: Adds a new card to the user's wallet using tokenization.

- **Get All Cards**
  - **Endpoint**: `/api/cards`
  - **Method**: GET
  - **Description**: Retrieves all cards saved in the user's wallet.

- **Edit Card**
  - **Endpoint**: `/api/cards/:token`
  - **Method**: PUT
  - **Description**: Updates details of a card using its token.

- **Delete Card**
  - **Endpoint**: `/api/cards/:token`
  - **Method**: DELETE
  - **Description**: Deletes a card using its token.

### QR Code Payment
- **Generate QR Code**
  - **Endpoint**: `/api/request-money`
  - **Method**: POST
  - **Description**: Generates a QR code for payment requests.

- **Fetch User Data**
  - **Endpoint**: `/api/login`
  - **Method**: POST
  - **Description**: Authenticates the user and fetches their data, including balance and user details.

## Database Structure
- **Collection**: `cards`
  - **Fields**:
    - `token`: Unique identifier for the card.
    - `cardHolderName`: Name of the cardholder.
    - `cardNumber`: (Encrypted)
    - `expiryDate`: Card expiry date.
    - `cardType`: Type of the card (e.g., Visa, MasterCard).
- **Collection**: `users`
  - **Fields**:
    - `fullName`: Full name of the user.
    - `username`: Unique username.
    - `email`: Email address.
    - `password`: (Encrypted) Password for authentication.
    - `birthday`: User's date of birth.
    - `mobilePhone`: User's mobile phone number.
    - `balance`: Current balance in the wallet.

## Backend API Implementation
The backend APIs are implemented using **Node.js** with **Express.js** and **MongoDB** for the database. Below are some key APIs:

- **User Authentication**: Login and register users with secure password hashing using **bcrypt**.
- **Transactions**: Transfer money, request money, and complete transactions with MongoDB transactions for data consistency.
- **QR Code Generation**: Generate QR codes for payment requests using the **qrcode** library.
- **Card Management**: Save, retrieve, and delete encrypted card details securely.

### Dockerfile for Backend
The backend Dockerfile is already included in the repository and is used to containerize the application efficiently.

## Security Measures
- **Tokenization**: Cards are identified and managed through tokens, reducing the risk of sensitive data exposure.
- **Encryption**: All sensitive card information is encrypted before storage in the database.

## Contribution
1. Fork the repository.
2. Create a new branch for your feature/bugfix:
   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add your message here"
   ```
4. Push the branch:
   ```bash
   git push origin feature-name
   ```
5. Open a Pull Request.

## License
This project is licensed under the MIT License. See the LICENSE file for more details.

## Contact
For any queries or support, please message me directly on [GitHub](https://github.com/halimo22).

