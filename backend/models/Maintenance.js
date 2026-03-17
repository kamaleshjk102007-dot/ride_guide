const mongoose = require("mongoose");

const maintenanceSchema = new mongoose.Schema(
  {
    ride_id: { type: mongoose.Schema.Types.ObjectId, ref: "Ride", required: true },
    maintenance_date: { type: Date, default: Date.now },
    technician: { type: String, required: true, trim: true },
    status: { type: String, enum: ["Scheduled", "In Progress", "Completed"], required: true },
    notes: { type: String, trim: true, default: "" }
  },
  { timestamps: true }
);

module.exports = mongoose.model("Maintenance", maintenanceSchema);
