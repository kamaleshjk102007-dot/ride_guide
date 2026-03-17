const bcrypt = require("bcryptjs");
const Visitor = require("../models/Visitor");
const { signToken } = require("../utils/token");

const register = async (req, res) => {
  try {
    const { name, email, phone, age, password } = req.body;
    const existingVisitor = await Visitor.findOne({ email });

    if (existingVisitor) {
      return res.status(400).json({ message: "Visitor account already exists." });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const visitor = await Visitor.create({
      name,
      email,
      phone,
      age,
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
    const { email, password } = req.body;

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
