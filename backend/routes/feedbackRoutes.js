const express = require("express");
const { createFeedback, getFeedback } = require("../controllers/feedbackController");

const router = express.Router();

router.post("/", createFeedback);
router.get("/", getFeedback);

module.exports = router;
