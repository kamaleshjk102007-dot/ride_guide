const mongoose = require("mongoose");

const feedbackSchema = new mongoose.Schema(
  {
    visitor_id: { type: mongoose.Schema.Types.ObjectId, ref: "Visitor", required: true },
    ride_id: { type: mongoose.Schema.Types.ObjectId, ref: "Ride", required: true },
    rating: { type: Number, required: true, min: 1, max: 5 },
    comment: { type: String, trim: true, default: "" },
    date: { type: Date, default: Date.now }
  },
  { timestamps: true }
);

module.exports = mongoose.model("Feedback", feedbackSchema);
