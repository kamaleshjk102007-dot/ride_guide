const QueueEntry = require("../models/Queue");
const Ride = require("../models/Ride");
const { estimateWaitTime } = require("../utils/queueUtils");
const queueEmitter = require("../utils/queueEmitter");

const getQueue = async (_req, res) => {
  try {
    const queue = await QueueEntry.find().populate("ride_id", "ride_name image capacity duration status type");
    res.json(queue);
  } catch (error) {
    res.status(500).json({ message: "Unable to fetch queue.", error: error.message });
  }
};

const updateQueue = async (req, res) => {
  try {
    const { ride_id, people_in_queue } = req.body;
    const ride = await Ride.findById(ride_id);

    if (!ride) {
      return res.status(404).json({ message: "Ride not found." });
    }

    const queue = await QueueEntry.findOneAndUpdate(
      { ride_id },
      { people_in_queue, current_wait_time: estimateWaitTime(ride, people_in_queue) },
      { new: true, upsert: true, runValidators: true }
    ).populate("ride_id", "ride_name image capacity duration status type");

    queueEmitter.emit("queueUpdated");
    res.json(queue);
  } catch (error) {
    res.status(400).json({ message: "Unable to update queue.", error: error.message });
  }
};

const streamQueue = async (req, res) => {
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");

  const pushQueue = async () => {
    const queue = await QueueEntry.find().populate("ride_id", "ride_name image capacity duration status type");
    res.write(`data: ${JSON.stringify(queue)}\n\n`);
  };

  await pushQueue();

  const listener = async () => {
    await pushQueue();
  };

  queueEmitter.on("queueUpdated", listener);

  req.on("close", () => {
    queueEmitter.off("queueUpdated", listener);
    res.end();
  });
};

module.exports = { getQueue, updateQueue, streamQueue };
