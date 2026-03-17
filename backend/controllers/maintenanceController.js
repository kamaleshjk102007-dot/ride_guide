const Maintenance = require("../models/Maintenance");

const getMaintenance = async (_req, res) => {
  try {
    const records = await Maintenance.find()
      .populate("ride_id", "ride_name status")
      .sort({ maintenance_date: -1 });

    res.json(records);
  } catch (error) {
    res.status(500).json({ message: "Unable to fetch maintenance records.", error: error.message });
  }
};

const createMaintenance = async (req, res) => {
  try {
    const record = await Maintenance.create({
      ...req.body,
      maintenance_date: req.body.maintenance_date || new Date()
    });

    res.status(201).json(record);
  } catch (error) {
    res.status(400).json({ message: "Unable to create maintenance record.", error: error.message });
  }
};

module.exports = { getMaintenance, createMaintenance };
