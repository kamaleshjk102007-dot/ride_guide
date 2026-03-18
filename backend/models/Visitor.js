const mongoose = require("mongoose");
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const phoneRegex = /^[0-9+\-\s]{7,15}$/;

const visitorSchema = new mongoose.Schema(
  {
    visitor_id: { type: String, required: true, unique: true, trim: true },
    visitor_sequence: { type: Number, required: true, unique: true },
    name: { type: String, required: true, trim: true },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
      match: [emailRegex, "Enter a valid email address."]
    },
    phone: {
      type: String,
      required: true,
      trim: true,
      match: [phoneRegex, "Enter a valid phone number."]
    },
    status: { type: String, enum: ["Active", "Expired"], default: "Active" },
    age: { type: Number, required: true, min: 1 },
    password: { type: String, required: true, minlength: 6, select: false },
    tickets: [{ type: mongoose.Schema.Types.ObjectId, ref: "Ticket" }]
  },
  { timestamps: true }
);

module.exports = mongoose.model("Visitor", visitorSchema);
