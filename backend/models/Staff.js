const mongoose = require("mongoose");

const staffSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    role: { type: String, required: true, trim: true },
    assigned_ride: { type: mongoose.Schema.Types.ObjectId, ref: "Ride", default: null },
    shift: { type: String, required: true, trim: true }
  },
  { timestamps: true }
);

module.exports = mongoose.model("Staff", staffSchema);
