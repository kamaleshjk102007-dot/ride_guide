const QRCode = require("qrcode");
const Ticket = require("../models/Ticket");
const Ride = require("../models/Ride");
const Visitor = require("../models/Visitor");
const QueueEntry = require("../models/Queue");
const { estimateWaitTime } = require("../utils/queueUtils");
const queueEmitter = require("../utils/queueEmitter");

const createTicket = async (req, res) => {
  try {
    const { visitor_id, ride_id, price } = req.body;

    const [visitor, ride] = await Promise.all([Visitor.findById(visitor_id), Ride.findById(ride_id)]);
    if (!visitor) {
      return res.status(404).json({ message: "Visitor not found." });
    }
    if (!ride) {
      return res.status(404).json({ message: "Ride not found." });
    }
    if (ride.status !== "Active") {
      return res.status(400).json({ message: "Ride is under maintenance." });
    }
    if (visitor.age < ride.min_age) {
      return res.status(400).json({ message: "Visitor does not meet the age requirement." });
    }

    const ticket = await Ticket.create({
      visitor_id,
      ride_id,
      price,
      booking_date: new Date(),
      status: "Booked"
    });

    visitor.tickets.push(ticket._id);
    await visitor.save();

    const queueEntry = await QueueEntry.findOne({ ride_id });
    if (queueEntry) {
      queueEntry.people_in_queue += 1;
      queueEntry.current_wait_time = estimateWaitTime(ride, queueEntry.people_in_queue);
      await queueEntry.save();
      queueEmitter.emit("queueUpdated");
    }

    const qrCode = await QRCode.toDataURL(
      JSON.stringify({
        ticketId: ticket._id,
        visitor: visitor.name,
        ride: ride.ride_name
      })
    );

    const ticketWithRide = await Ticket.findById(ticket._id)
      .populate("ride_id", "ride_name type image")
      .populate("visitor_id", "name email");

    res.status(201).json({ ticket: ticketWithRide, qrCode });
  } catch (error) {
    res.status(400).json({ message: "Unable to create ticket.", error: error.message });
  }
};

const getVisitorTickets = async (req, res) => {
  try {
    const tickets = await Ticket.find({ visitor_id: req.params.visitor_id })
      .populate("ride_id", "ride_name type image status duration")
      .sort({ booking_date: -1 });

    res.json(tickets);
  } catch (error) {
    res.status(500).json({ message: "Unable to fetch tickets.", error: error.message });
  }
};

module.exports = { createTicket, getVisitorTickets };
