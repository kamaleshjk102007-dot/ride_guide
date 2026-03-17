const mongoose = require("mongoose");

const rideSchema = new mongoose.Schema(
  {
    ride_name: { type: String, required: true, trim: true },
    type: { type: String, enum: ["thrill", "family", "water"], required: true },
    description: { type: String, default: "" },
    image: { type: String, default: "" },
    min_age: { type: Number, required: true, min: 0 },
    capacity: { type: Number, required: true, min: 1 },
    duration: { type: Number, required: true, min: 1 },
    status: { type: String, enum: ["Active", "Maintenance"], default: "Active" }
  },
  { timestamps: true }
);

module.exports = mongoose.model("Ride", rideSchema);
