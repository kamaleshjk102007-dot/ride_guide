const Visitor = require("../models/Visitor");
const Ride = require("../models/Ride");
const Ticket = require("../models/Ticket");
const Payment = require("../models/Payment");
const QueueEntry = require("../models/Queue");
const Feedback = require("../models/Feedback");

const getDashboardStats = async (_req, res) => {
  try {
    const [totalVisitors, totalRides, activeTickets, revenueResult, queues, avgRatingResult] = await Promise.all([
      Visitor.countDocuments(),
      Ride.countDocuments(),
      Ticket.countDocuments({ status: "Booked" }),
      Payment.aggregate([{ $group: { _id: null, totalRevenue: { $sum: "$amount" } } }]),
      QueueEntry.find().populate("ride_id", "ride_name"),
      Feedback.aggregate([{ $group: { _id: null, avgRating: { $avg: "$rating" } } }])
    ]);

    res.json({
      cards: {
        totalVisitors,
        totalRides,
        activeTickets,
        revenue: revenueResult[0]?.totalRevenue || 0,
        averageRating: Number((avgRatingResult[0]?.avgRating || 0).toFixed(1))
      },
      queueLoad: queues
    });
  } catch (error) {
    res.status(500).json({ message: "Unable to fetch dashboard stats.", error: error.message });
  }
};

const getRidePopularity = async (_req, res) => {
  try {
    const popularity = await Ticket.aggregate([
      { $match: { status: { $ne: "Cancelled" } } },
      { $group: { _id: "$ride_id", bookings: { $sum: 1 }, revenue: { $sum: "$price" } } },
      {
        $lookup: {
          from: "rides",
          localField: "_id",
          foreignField: "_id",
          as: "ride"
        }
      },
      { $unwind: "$ride" },
      {
        $project: {
          _id: 0,
          rideId: "$ride._id",
          ride_name: "$ride.ride_name",
          bookings: 1,
          revenue: 1
        }
      },
      { $sort: { bookings: -1 } }
    ]);

    res.json(popularity);
  } catch (error) {
    res.status(500).json({ message: "Unable to fetch ride popularity.", error: error.message });
  }
};

const getVisitorStats = async (_req, res) => {
  try {
    const stats = await Visitor.aggregate([
      {
        $group: {
          _id: null,
          averageAge: { $avg: "$age" },
          visitorCount: { $sum: 1 }
        }
      }
    ]);

    res.json(stats[0] || { averageAge: 0, visitorCount: 0 });
  } catch (error) {
    res.status(500).json({ message: "Unable to fetch visitor statistics.", error: error.message });
  }
};

module.exports = { getDashboardStats, getRidePopularity, getVisitorStats };
