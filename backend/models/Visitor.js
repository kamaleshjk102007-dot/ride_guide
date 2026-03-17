const mongoose = require("mongoose");

const visitorSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, trim: true, lowercase: true },
    phone: { type: String, required: true, trim: true },
    age: { type: Number, required: true, min: 1 },
    password: { type: String, required: true, minlength: 6, select: false },
    tickets: [{ type: mongoose.Schema.Types.ObjectId, ref: "Ticket" }]
  },
  { timestamps: true }
);

module.exports = mongoose.model("Visitor", visitorSchema);
