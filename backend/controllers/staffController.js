const Staff = require("../models/Staff");

const getStaff = async (_req, res) => {
  try {
    const staff = await Staff.find().populate("assigned_ride", "ride_name");
    res.json(staff);
  } catch (error) {
    res.status(500).json({ message: "Unable to fetch staff.", error: error.message });
  }
};

const createStaff = async (req, res) => {
  try {
    const staff = await Staff.create(req.body);
    res.status(201).json(staff);
  } catch (error) {
    res.status(400).json({ message: "Unable to create staff member.", error: error.message });
  }
};

const updateStaff = async (req, res) => {
  try {
    const staff = await Staff.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    }).populate("assigned_ride", "ride_name");

    if (!staff) {
      return res.status(404).json({ message: "Staff member not found." });
    }

    res.json(staff);
  } catch (error) {
    res.status(400).json({ message: "Unable to update staff member.", error: error.message });
  }
};

module.exports = { getStaff, createStaff, updateStaff };
