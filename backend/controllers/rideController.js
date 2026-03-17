const Ride = require("../models/Ride");
const QueueEntry = require("../models/Queue");

const getRides = async (_req, res) => {
  try {
    const rides = await Ride.find().sort({ createdAt: -1 });
    res.json(rides);
  } catch (error) {
    res.status(500).json({ message: "Unable to fetch rides.", error: error.message });
  }
};

const createRide = async (req, res) => {
  try {
    const ride = await Ride.create(req.body);
    await QueueEntry.create({ ride_id: ride._id });
    res.status(201).json(ride);
  } catch (error) {
    res.status(400).json({ message: "Unable to create ride.", error: error.message });
  }
};

const updateRide = async (req, res) => {
  try {
    const ride = await Ride.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });

    if (!ride) {
      return res.status(404).json({ message: "Ride not found." });
    }

    res.json(ride);
  } catch (error) {
    res.status(400).json({ message: "Unable to update ride.", error: error.message });
  }
};

const deleteRide = async (req, res) => {
  try {
    const ride = await Ride.findByIdAndDelete(req.params.id);

    if (!ride) {
      return res.status(404).json({ message: "Ride not found." });
    }

    await QueueEntry.findOneAndDelete({ ride_id: req.params.id });
    res.json({ message: "Ride deleted successfully." });
  } catch (error) {
    res.status(500).json({ message: "Unable to delete ride.", error: error.message });
  }
};

module.exports = { getRides, createRide, updateRide, deleteRide };
