const mongoose = require("mongoose");

const ticketSchema = new mongoose.Schema(
  {
    visitor_id: { type: mongoose.Schema.Types.ObjectId, ref: "Visitor", required: true },
    ride_id: { type: mongoose.Schema.Types.ObjectId, ref: "Ride", required: true },
    booking_date: { type: Date, default: Date.now },
    price: { type: Number, required: true, min: 0 },
    status: { type: String, enum: ["Booked", "Cancelled", "Used"], default: "Booked" }
  },
  { timestamps: true }
);

module.exports = mongoose.model("Ticket", ticketSchema);
