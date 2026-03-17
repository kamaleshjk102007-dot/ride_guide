const bcrypt = require("bcryptjs");
const Visitor = require("../models/Visitor");
const { signToken } = require("../utils/token");
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const phoneRegex = /^[0-9+\-\s]{7,15}$/;

const register = async (req, res) => {
  try {
    const { name, email, phone, age, password } = req.body;
    const normalizedName = String(name ?? "").trim();
    const normalizedEmail = String(email ?? "").trim().toLowerCase();
    const normalizedPhone = String(phone ?? "").trim();
    const parsedAge = Number(age);
    const normalizedPassword = String(password ?? "");

    if (!normalizedName || !normalizedEmail || !normalizedPhone || !normalizedPassword || !parsedAge) {
      return res.status(400).json({ message: "All registration fields are required." });
    }

    if (!emailRegex.test(normalizedEmail)) {
      return res.status(400).json({ message: "Enter a valid email address." });
    }

    if (!phoneRegex.test(normalizedPhone)) {
      return res.status(400).json({ message: "Enter a valid phone number." });
    }

    if (parsedAge <= 0) {
      return res.status(400).json({ message: "Enter a valid age." });
    }

    if (normalizedPassword.length < 6) {
      return res.status(400).json({ message: "Password must be at least 6 characters." });
    }

    const existingVisitor = await Visitor.findOne({ email: normalizedEmail });

    if (existingVisitor) {
      return res.status(400).json({ message: "Visitor account already exists." });
    }

    const hashedPassword = await bcrypt.hash(normalizedPassword, 10);
    const visitor = await Visitor.create({
      name: normalizedName,
      email: normalizedEmail,
      phone: normalizedPhone,
      age: parsedAge,
      password: hashedPassword
    });

    const token = signToken({ id: visitor._id, role: "visitor" });

    res.status(201).json({
      token,
      user: {
        _id: visitor._id,
        name: visitor.name,
        email: visitor.email,
        phone: visitor.phone,
        age: visitor.age,
        role: "visitor"
      }
    });
  } catch (error) {
    res.status(400).json({ message: "Unable to register visitor.", error: error.message });
  }
};

const login = async (req, res) => {
  try {
    const email = String(req.body.email ?? "").trim().toLowerCase();
    const password = String(req.body.password ?? "");

    if (!email || !password) {
      return res.status(400).json({ message: "Email and password are required." });
    }

    if (!emailRegex.test(email)) {
      return res.status(400).json({ message: "Enter a valid email address." });
    }

    if (email === process.env.ADMIN_EMAIL && password === process.env.ADMIN_PASSWORD) {
      const token = signToken({ email, role: "admin" });
      return res.json({
        token,
        user: {
          name: "Park Admin",
          email,
          role: "admin"
        }
      });
    }

    const visitor = await Visitor.findOne({ email }).select("+password");
    if (!visitor) {
      return res.status(401).json({ message: "Invalid credentials." });
    }

    const isMatch = await bcrypt.compare(password, visitor.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid credentials." });
    }

    const token = signToken({ id: visitor._id, role: "visitor" });

    res.json({
      token,
      user: {
        _id: visitor._id,
        name: visitor.name,
        email: visitor.email,
        phone: visitor.phone,
        age: visitor.age,
        role: "visitor"
      }
    });
  } catch (error) {
    res.status(500).json({ message: "Unable to login.", error: error.message });
  }
};

module.exports = { register, login };
