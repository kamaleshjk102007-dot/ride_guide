const express = require("express");
const { createTicket, getVisitorTickets } = require("../controllers/ticketController");

const router = express.Router();

router.post("/", createTicket);
router.get("/:visitor_id", getVisitorTickets);

module.exports = router;
