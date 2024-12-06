import { MongoClient } from "mongodb";
import dotenv from 'dotenv';
import express from "express";
import bcrypt from "bcrypt";
import { v4 as uuidv4 } from 'uuid';
import QRCode from 'qrcode';


const app = express();
dotenv.config();
app.use(express.json());
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
    const { firstName, lastName, email, password, birthday } = req.body;

    if (!firstName || !lastName || !email || !password || !birthday) {
        return res.status(400).json({ message: "First name, last name, email, password, and birthday are required" });
    }

    try {
        const db = await connectToDatabase();
        const usersCollection = db.collection("users");

        const existingUser = await usersCollection.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: "User with this email already exists" });
        }

        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        const newUser = {
            firstName,
            lastName,
            email,
            password: hashedPassword,
            birthday: new Date(birthday),
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

        // Start transaction
        await session.withTransaction(async () => {
            // Find sender
            const sender = await usersCollection.findOne({ email: senderEmail });
            if (!sender) {
                throw new Error("Sender not found");
            }

            // Check if sender has sufficient balance
            if (sender.balance < amount) {
                throw new Error("Insufficient balance");
            }

            // Find recipient
            const recipient = await usersCollection.findOne({ email: recipientEmail });
            if (!recipient) {
                throw new Error("Recipient not found");
            }

            // Update sender's balance
            await usersCollection.updateOne(
                { email: senderEmail },
                { $inc: { balance: -amount } },
                { session }
            );

            // Update recipient's balance
            await usersCollection.updateOne(
                { email: recipientEmail },
                { $inc: { balance: amount } },
                { session }
            );

            // Optionally, log the transaction
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
    const { senderEmail, receiverEmail, amount } = req.body;

    if (!senderEmail || !receiverEmail || !amount || amount <= 0) {
        return res.status(400).json({
            message: "Sender email, receiver email, and valid amount are required",
        });
    }

    try {
        const db = await connectToDatabase();
        const transactionsCollection = db.collection("transactions");

        const transactionId = uuidv4(); // Generate a unique transaction ID

        const transaction = {
            transactionId,
            senderEmail,
            receiverEmail,
            amount,
            status: "pending",
            createdAt: new Date(),
        };

        // Save the transaction to the database
        await transactionsCollection.insertOne(transaction);

        // Generate a QR code
        const qrCodeData = await QRCode.toDataURL(transactionId);

        return res.status(201).json({
            message: "Transaction created successfully",
            transactionId,
            qrCode: qrCodeData,
        });
    } catch (err) {
        console.error("Error creating money request", err);
        return res.status(500).json({ message: "Internal server error" });
    }
});


app.post("/complete-transaction", async (req, res) => {
    const { transactionId, receiverEmail } = req.body;

    if (!transactionId || !receiverEmail) {
        return res.status(400).json({
            message: "Transaction ID and receiver email are required",
        });
    }

    try {
        const db = await connectToDatabase();
        const usersCollection = db.collection("users");
        const transactionsCollection = db.collection("transactions");

        // Fetch the transaction
        const transaction = await transactionsCollection.findOne({ transactionId });

        if (!transaction) {
            return res.status(404).json({ message: "Transaction not found" });
        }

        if (transaction.status !== "pending") {
            return res.status(400).json({ message: "Transaction is already completed or canceled" });
        }

        if (transaction.receiverEmail !== receiverEmail) {
            return res.status(403).json({ message: "You are not authorized to complete this transaction" });
        }

        // Fetch sender and receiver
        const sender = await usersCollection.findOne({ email: transaction.senderEmail });
        const receiver = await usersCollection.findOne({ email: receiverEmail });

        if (!sender || !receiver) {
            return res.status(404).json({ message: "Sender or receiver not found" });
        }

        if (receiver.balance < transaction.amount) {
            return res.status(400).json({ message: "Insufficient balance in receiver's account" });
        }

        // Start a session for atomic updates
        const session = client.startSession();
        await session.withTransaction(async () => {
            // Deduct amount from receiver's balance
            await usersCollection.updateOne(
                { email: receiverEmail },
                { $inc: { balance: -transaction.amount } },
                { session }
            );

            // Add amount to sender's balance
            await usersCollection.updateOne(
                { email: transaction.senderEmail },
                { $inc: { balance: transaction.amount } },
                { session }
            );

            // Mark the transaction as completed
            await transactionsCollection.updateOne(
                { transactionId },
                { $set: { status: "completed", completedAt: new Date() } },
                { session }
            );
        });

        session.endSession();

        return res.status(200).json({ message: "Transaction completed successfully" });
    } catch (err) {
        console.error("Error completing transaction", err);
        return res.status(500).json({ message: "Internal server error" });
    }
});




app.listen(port, () => {
    console.log("Server is running on port:" + port );
});


