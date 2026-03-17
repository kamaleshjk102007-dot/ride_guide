const express = require("express");
const { getDashboardStats, getRidePopularity, getVisitorStats } = require("../controllers/analyticsController");

const router = express.Router();

router.get("/dashboard", getDashboardStats);
router.get("/ride-popularity", getRidePopularity);
router.get("/visitor-stats", getVisitorStats);

module.exports = router;
