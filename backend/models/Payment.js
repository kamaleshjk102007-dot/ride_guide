const mongoose = require("mongoose");

const paymentSchema = new mongoose.Schema(
  {
    ticket_id: { type: mongoose.Schema.Types.ObjectId, ref: "Ticket", required: true },
    visitor_id: { type: mongoose.Schema.Types.ObjectId, ref: "Visitor", required: true },
    amount: { type: Number, required: true, min: 0 },
    payment_method: { type: String, enum: ["Cash", "Card", "UPI", "Wallet"], required: true },
    payment_date: { type: Date, default: Date.now }
  },
  { timestamps: true }
);

module.exports = mongoose.model("Payment", paymentSchema);
