const express = require("express");
const { getQueue, updateQueue, streamQueue } = require("../controllers/queueController");

const router = express.Router();

router.get("/", getQueue);
router.get("/stream", streamQueue);
router.put("/", updateQueue);

module.exports = router;
