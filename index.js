import { MongoClient } from "mongodb";
import { ObjectId } from "mongodb";
import dotenv from 'dotenv';
import express from "express";
import bcrypt from "bcrypt";
import { v4 as uuidv4 } from 'uuid';
import QRCode from 'qrcode';
import crypto from 'crypto';
import CryptoJS from 'crypto-js';
import cors from 'cors';
const app = express();
dotenv.config();
app.use(express.json());
app.use(cors());
const uri = process.env.MONGO_URI;
const port = process.env.PORT;
const client = new MongoClient(uri);

async function connectToDatabase() {
    try {
        await client.connect();
        console.log("Connected successfully to MongoDB");
        return client.db("ma7fazty");
    } catch (err) {
        console.error("Connection to MongoDB failed", err);
        throw err;
    }
}

app.get('/api/connectivity', (req, res) => {
    res.status(200).json({
      status: 'success',
      message: 'Server is online',
      timestamp: new Date().toISOString(),
    });
  });
  app.post("/login", async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ message: "Email and password are required" });
    }

    try {
        const db = await connectToDatabase();
        const usersCollection = db.collection("users");

        const user = await usersCollection.findOne({ email });
        if (!user) {
            return res.status(401).json({ message: "Invalid email or password" });
        }

        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            return res.status(401).json({ message: "Invalid email or password" });
        }

        const { password: _, ...userWithoutPassword } = user;
        return res.status(200).json({ message: "Login successful", user: userWithoutPassword });
    } catch (err) {
        console.error("Error during login", err);
        return res.status(500).json({ message: "Internal server error" });
    }
});


app.post("/users", async (req, res) => {
    const { fullName, username, email, password, birthday, mobilePhone } = req.body;

    if (!fullName || !username || !email || !password || !birthday || !mobilePhone) {
        return res.status(400).json({ message: "Full name, username, email, password, birthday, and mobile phone are required" });
    }

    try {
        const db = await connectToDatabase();
        const usersCollection = db.collection("users");

        const existingUser = await usersCollection.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: "User with this email already exists" });
        }

        const existingUsername = await usersCollection.findOne({ username });
        if (existingUsername) {
            return res.status(400).json({ message: "Username is already taken" });
        }

        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        const newUser = {
            fullName,
            username,
            email,
            password: hashedPassword,
            birthday: new Date(birthday),
            mobilePhone,
            balance: 0,
            cards: [],
            transactions: [],
            createdAt: new Date(),
        };

        const result = await usersCollection.insertOne(newUser);

        const { password: _, ...userWithoutPassword } = newUser;
        return res.status(201).json({ message: "User created successfully", user: userWithoutPassword });
    } catch (err) {
        console.error("Error creating user", err);
        return res.status(500).json({ message: "Internal server error" });
    }
});

app.post("/transfer", async (req, res) => {
    const { senderEmail, recipientEmail, amount } = req.body;

    if (!senderEmail || !recipientEmail || !amount) {
        return res.status(400).json({ message: "Sender email, recipient email, and amount are required" });
    }

    if (amount <= 0) {
        return res.status(400).json({ message: "Amount must be greater than zero" });
    }

    try {
        const db = await connectToDatabase();
        const usersCollection = db.collection("users");

        const session = client.startSession();

        await session.withTransaction(async () => {
            const sender = await usersCollection.findOne({ email: senderEmail });
            if (!sender) {
                throw new Error("Sender not found");
            }

            if (sender.balance < amount) {
                throw new Error("Insufficient balance");
            }

            const recipient = await usersCollection.findOne({ email: recipientEmail });
            if (!recipient) {
                throw new Error("Recipient not found");
            }

            await usersCollection.updateOne(
                { email: senderEmail },
                { $inc: { balance: -amount } },
                { session }
            );

            await usersCollection.updateOne(
                { email: recipientEmail },
                { $inc: { balance: amount } },
                { session }
            );

            const transaction = {
                from: senderEmail,
                to: recipientEmail,
                amount,
                date: new Date(),
            };

            await db.collection("transactions").insertOne(transaction, { session });
        });

        session.endSession();

        return res.status(200).json({ message: "Transaction successful" });
    } catch (err) {
        console.error("Error during money transfer", err);
        return res.status(500).json({ message: err.message || "Internal server error" });
    }
});

app.post("/request-money", async (req, res) => {
    const { receiverEmail, amount } = req.body;

    if (!receiverEmail || !amount || amount <= 0) {
        return res.status(400).json({
            message: "Receiver email and a valid amount are required",
        });
    }

    try {
        const db = await connectToDatabase();
        const transactionsCollection = db.collection("transactions");

        const transaction = {
            receiverEmail,
            amount,
            senderEmail: null, // Placeholder for now
            status: "pending",
            createdAt: new Date(),
        };

        const result = await transactionsCollection.insertOne(transaction);

        // Use MongoDB's `_id` as the unique transaction identifier
        const transactionId = result.insertedId.toString();
        const qrCodeData = await QRCode.toDataURL(transactionId);

        return res.status(201).json({
            message: "Money request created successfully",
            transactionId,
            qrCode: qrCodeData,
        });
    } catch (err) {
        console.error("Error creating money request", err);
        return res.status(500).json({ message: "Internal server error" });
    }
});


app.post("/complete-transaction", async (req, res) => {
    const { transactionId, senderEmail } = req.body;

    if (!transactionId || !senderEmail) {
        return res.status(400).json({
            message: "Transaction ID and sender email are required",
        });
    }

    try {
        const db = await connectToDatabase();
        const usersCollection = db.collection("users");
        const transactionsCollection = db.collection("transactions");

        // Convert transactionId to an ObjectId
        const transaction = await transactionsCollection.findOne({ _id: new ObjectId(transactionId) });

        if (!transaction) {
            return res.status(404).json({ message: "Transaction not found" });
        }

        if (transaction.status !== "pending") {
            return res.status(400).json({ message: "Transaction is already completed or canceled" });
        }

        const sender = await usersCollection.findOne({ email: senderEmail });
        const receiver = await usersCollection.findOne({ email: transaction.receiverEmail });

        if (!sender || !receiver) {
            return res.status(404).json({ message: "Sender or receiver not found" });
        }

        // Always proceed with the transaction, no balance check
        await usersCollection.updateOne(
            { email: senderEmail },
            { $inc: { balance: -transaction.amount } }
        );

        await usersCollection.updateOne(
            { email: transaction.receiverEmail },
            { $inc: { balance: transaction.amount } }
        );

        // Update transaction with senderEmail and mark as completed
        await transactionsCollection.updateOne(
            { _id: new ObjectId(transactionId) },
            { $set: { senderEmail, status: "completed", completedAt: new Date() } }
        );

        return res.status(200).json({
            message: "Transaction completed successfully",
        });
    } catch (err) {
        console.error("Error completing transaction", err);
        return res.status(500).json({ message: "Internal server error" });
    }
});

function encryptCard(cardNumber) {
    const secretKey = process.env.SECRET_KEY || 'your-encryption-key';
    const encrypted = CryptoJS.AES.encrypt(cardNumber, secretKey).toString();
    return encrypted;
}

app.post("/save-card", async (req, res) => {
    const { email, cardNumber, cardHolderName, expiryDate } = req.body;

    if (!email || !cardNumber || !cardHolderName || !expiryDate) {
        return res.status(400).json({ message: "All fields are required" });
    }

    try {
        const db = await connectToDatabase();
        const usersCollection = db.collection("users");

        const user = await usersCollection.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        const encryptedCard = encryptCard(cardNumber);

        const last4 = cardNumber.slice(-4);

        const newCard = {
            cardHolderName,
            last4,
            cardToken: encryptedCard,
            expiryDate,
            createdAt: new Date(),
        };

        await usersCollection.updateOne(
            { email },
            { $push: { cards: newCard } }
        );

        return res.status(200).json({ message: "Card saved successfully" });
    } catch (err) {
        console.error("Error saving card", err);
        return res.status(500).json({ message: "Internal server error" });
    }
});

app.get("/get-cards", async (req, res) => {
    const { email } = req.query;

    if (!email) {
        return res.status(400).json({ message: "Email is required" });
    }

    try {
        const db = await connectToDatabase();
        const usersCollection = db.collection("users");

        const user = await usersCollection.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        const cards = user.cards.map(card => ({
            cardHolderName: card.cardHolderName,
            last4: card.last4,
            expiryDate: card.expiryDate,
            createdAt: card.createdAt,
            cardToekn: card.cardToken,
        }));

        return res.status(200).json({ cards });
    } catch (err) {
        console.error("Error retrieving cards", err);
        return res.status(500).json({ message: "Internal server error" });
    }
});

app.get("/get-transactions", async (req, res) => {
    const { email, startDate, endDate, type } = req.query;

    if (!email) {
        return res.status(400).json({ message: "Email is required" });
    }

    try {
        const db = await connectToDatabase();
        const transactionsCollection = db.collection("transactions");

        const query = {
            $or: [{ from: email }, { to: email }]
        };

        // Filter by type (sent or received)
        if (type === "sent") {
            query.from = email;
            delete query.to; // Remove 'to' to avoid conflicts
        } else if (type === "received") {
            query.to = email;
            delete query.from; // Remove 'from' to avoid conflicts
        }

        // Filter by date range if provided
        if (startDate || endDate) {
            query.date = {};
            if (startDate) query.date.$gte = new Date(startDate);
            if (endDate) query.date.$lte = new Date(endDate);
        }

        const transactions = await transactionsCollection.find(query).toArray();

        return res.status(200).json({ transactions });
    } catch (err) {
        console.error("Error retrieving transactions", err);
        return res.status(500).json({ message: "Internal server error" });
    }
});


app.delete("/delete-card", async (req, res) => {
    const { email, cardToken } = req.body;

    if (!email || !cardToken) {
        return res.status(400).json({ message: "Email and card token are required" });
    }

    try {
        const db = await connectToDatabase();
        const usersCollection = db.collection("users");

        const user = await usersCollection.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        const cardIndex = user.cards.findIndex(card => card.cardToken === cardToken);

        if (cardIndex === -1) {
            return res.status(404).json({ message: "Card not found" });
        }

        user.cards.splice(cardIndex, 1);

        await usersCollection.updateOne(
            { email },
            { $set: { cards: user.cards } }
        );

        return res.status(200).json({ message: "Card deleted successfully" });
    } catch (err) {
        console.error("Error deleting card", err);
        return res.status(500).json({ message: "Internal server error" });
    }
});

app.listen(port,'0.0.0.0', () => {
    console.log("Server is running on port:" + port );
});
