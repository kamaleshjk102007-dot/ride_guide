const mongoose = require("mongoose");

const queueSchema = new mongoose.Schema(
  {
    ride_id: { type: mongoose.Schema.Types.ObjectId, ref: "Ride", required: true, unique: true },
    people_in_queue: { type: Number, default: 0, min: 0 },
    current_wait_time: { type: Number, default: 0, min: 0 }
  },
  { timestamps: true, collection: "queue" }
);

module.exports = mongoose.model("QueueEntry", queueSchema);
