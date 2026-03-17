const express = require("express");
const { getStaff, createStaff, updateStaff } = require("../controllers/staffController");

const router = express.Router();

router.get("/", getStaff);
router.post("/", createStaff);
router.put("/:id", updateStaff);

module.exports = router;
