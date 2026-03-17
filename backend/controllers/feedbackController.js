const Feedback = require("../models/Feedback");

const createFeedback = async (req, res) => {
  try {
    const feedback = await Feedback.create({
      ...req.body,
      date: new Date()
    });

    res.status(201).json(feedback);
  } catch (error) {
    res.status(400).json({ message: "Unable to create feedback.", error: error.message });
  }
};

const getFeedback = async (_req, res) => {
  try {
    const feedback = await Feedback.find()
      .populate("visitor_id", "name")
      .populate("ride_id", "ride_name")
      .sort({ date: -1 });

    res.json(feedback);
  } catch (error) {
    res.status(500).json({ message: "Unable to fetch feedback.", error: error.message });
  }
};

module.exports = { createFeedback, getFeedback };
