import { MongoClient } from "mongodb";
import dotenv from 'dotenv';
import express from "express";
import bcrypt from "bcrypt";

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

app.listen(port, () => {
    console.log("Server is running on port:" + port );
});


