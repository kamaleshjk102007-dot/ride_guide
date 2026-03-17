const Payment = require("../models/Payment");
const Ticket = require("../models/Ticket");

const createPayment = async (req, res) => {
  try {
    const { ticket_id, visitor_id, amount, payment_method } = req.body;
    const ticket = await Ticket.findById(ticket_id);

    if (!ticket) {
      return res.status(404).json({ message: "Ticket not found." });
    }

    const payment = await Payment.create({
      ticket_id,
      visitor_id,
      amount,
      payment_method,
      payment_date: new Date()
    });

    res.status(201).json(payment);
  } catch (error) {
    res.status(400).json({ message: "Unable to create payment.", error: error.message });
  }
};

const getPayments = async (_req, res) => {
  try {
    const payments = await Payment.find()
      .populate("visitor_id", "name email")
      .populate("ticket_id", "price status")
      .sort({ payment_date: -1 });

    res.json(payments);
  } catch (error) {
    res.status(500).json({ message: "Unable to fetch payments.", error: error.message });
  }
};

module.exports = { createPayment, getPayments };
