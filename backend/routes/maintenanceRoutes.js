const express = require("express");
const { getMaintenance, createMaintenance } = require("../controllers/maintenanceController");

const router = express.Router();

router.get("/", getMaintenance);
router.post("/", createMaintenance);

module.exports = router;
