require("dotenv").config({ path: require("path").join(__dirname, "..", ".env") });
const bcrypt = require("bcryptjs");
const connectDB = require("../config/db");
const Visitor = require("../models/Visitor");
const Ride = require("../models/Ride");
const Ticket = require("../models/Ticket");
const Payment = require("../models/Payment");
const Staff = require("../models/Staff");
const Maintenance = require("../models/Maintenance");
const Feedback = require("../models/Feedback");
const QueueEntry = require("../models/Queue");
const { estimateWaitTime } = require("./queueUtils");

const seed = async () => {
  await connectDB();

  await Promise.all([
    Visitor.deleteMany({}),
    Ride.deleteMany({}),
    Ticket.deleteMany({}),
    Payment.deleteMany({}),
    Staff.deleteMany({}),
    Maintenance.deleteMany({}),
    Feedback.deleteMany({}),
    QueueEntry.deleteMany({})
  ]);

  const password = await bcrypt.hash("visitor123", 10);

  const visitors = await Visitor.insertMany([
    { visitor_id: "VST1001", visitor_sequence: 1001, name: "Rahul Kumar", email: "rahul@gmail.com", phone: "9876543210", status: "Active", age: 22, password },
    { visitor_id: "VST1002", visitor_sequence: 1002, name: "Ananya Singh", email: "ananya@gmail.com", phone: "9811122233", status: "Active", age: 19, password },
    { visitor_id: "VST1003", visitor_sequence: 1003, name: "Vikram Das", email: "vikram@gmail.com", phone: "9988776655", status: "Active", age: 31, password }
  ]);

  const rides = await Ride.insertMany([
    {
      ride_name: "Roller Coaster",
      type: "thrill",
      description: "A high-speed coaster with twisting rails, drops, and a roaring grand finale.",
      image: "assets/images/roller_coaster.jpg",
      min_age: 16,
      capacity: 24,
      duration: 5,
      status: "Active"
    },
    {
      ride_name: "Ferris Wheel",
      type: "family",
      description: "A giant observation wheel with glowing cabins and a panoramic sunset view of the park.",
      image: "assets/images/ferris_wheel.jpg",
      min_age: 5,
      capacity: 30,
      duration: 8,
      status: "Active"
    },
    {
      ride_name: "Carousel (Merry-Go-Round)",
      type: "family",
      description: "A colorful classic carousel with painted horses, music, and family-friendly charm.",
      image: "assets/images/carousel.jpg",
      min_age: 3,
      capacity: 26,
      duration: 6,
      status: "Active"
    },
    {
      ride_name: "Drop Tower",
      type: "thrill",
      description: "A vertical thrill ride that lifts guests sky-high before a dramatic free-fall drop.",
      image: "assets/images/drop_tower.jpg",
      min_age: 14,
      capacity: 18,
      duration: 5,
      status: "Active"
    },
    {
      ride_name: "Bumper Cars",
      type: "family",
      description: "An energetic arena where guests steer, spin, and bump through playful electric chaos.",
      image: "assets/images/bumper_cars.jpg",
      min_age: 8,
      capacity: 22,
      duration: 7,
      status: "Active"
    },
    {
      ride_name: "Water Splash Ride",
      type: "water",
      description: "A water coaster with twists, drifting channels, and a final splash-zone finish.",
      image: "assets/images/water_splash_ride.jpg",
      min_age: 10,
      capacity: 18,
      duration: 6,
      status: "Maintenance"
    }
  ]);

  const tickets = await Ticket.insertMany([
    { visitor_id: visitors[0]._id, visitor_code: visitors[0].visitor_id, ride_id: rides[0]._id, booking_date: new Date(), price: 450, status: "Booked" },
    { visitor_id: visitors[1]._id, visitor_code: visitors[1].visitor_id, ride_id: rides[1]._id, booking_date: new Date(), price: 320, status: "Booked" },
    { visitor_id: visitors[2]._id, visitor_code: visitors[2].visitor_id, ride_id: rides[2]._id, booking_date: new Date(), price: 280, status: "Booked" },
    { visitor_id: visitors[0]._id, visitor_code: visitors[0].visitor_id, ride_id: rides[4]._id, booking_date: new Date(), price: 300, status: "Booked" }
  ]);

  visitors[0].tickets = [tickets[0]._id, tickets[3]._id];
  visitors[1].tickets = [tickets[1]._id];
  visitors[2].tickets = [tickets[2]._id];
  await Promise.all(visitors.map((visitor) => visitor.save()));

  await Payment.insertMany([
    { ticket_id: tickets[0]._id, visitor_id: visitors[0]._id, visitor_code: visitors[0].visitor_id, amount: 450, payment_method: "UPI", payment_date: new Date() },
    { ticket_id: tickets[1]._id, visitor_id: visitors[1]._id, visitor_code: visitors[1].visitor_id, amount: 320, payment_method: "Card", payment_date: new Date() },
    { ticket_id: tickets[2]._id, visitor_id: visitors[2]._id, visitor_code: visitors[2].visitor_id, amount: 280, payment_method: "Wallet", payment_date: new Date(Date.now() - 86400000) },
    { ticket_id: tickets[3]._id, visitor_id: visitors[0]._id, visitor_code: visitors[0].visitor_id, amount: 300, payment_method: "Cash", payment_date: new Date() }
  ]);

  await Staff.insertMany([
    { name: "Nisha Arora", role: "Ride Operator", assigned_ride: rides[0]._id, shift: "Morning" },
    { name: "Farhan Ali", role: "Safety Supervisor", assigned_ride: rides[1]._id, shift: "Evening" },
    { name: "Kriti Mehta", role: "Floor Host", assigned_ride: rides[4]._id, shift: "Afternoon" }
  ]);

  await Maintenance.insertMany([
    {
      ride_id: rides[5]._id,
      maintenance_date: new Date(),
      technician: "Arjun Patel",
      status: "In Progress",
      notes: "Pump pressure inspection and water tunnel lighting replacement."
    }
  ]);

  await Feedback.insertMany([
    { visitor_id: visitors[0]._id, ride_id: rides[0]._id, rating: 5, comment: "Brilliant energy and smooth operation.", date: new Date() },
    { visitor_id: visitors[1]._id, ride_id: rides[1]._id, rating: 5, comment: "Amazing evening view from the top cabin.", date: new Date() },
    { visitor_id: visitors[2]._id, ride_id: rides[4]._id, rating: 4, comment: "Bumper Cars were chaotic and fun for the whole group.", date: new Date() }
  ]);

  await QueueEntry.insertMany([
    { ride_id: rides[0]._id, people_in_queue: 42, current_wait_time: estimateWaitTime(rides[0], 42) },
    { ride_id: rides[1]._id, people_in_queue: 18, current_wait_time: estimateWaitTime(rides[1], 18) },
    { ride_id: rides[2]._id, people_in_queue: 27, current_wait_time: estimateWaitTime(rides[2], 27) },
    { ride_id: rides[3]._id, people_in_queue: 21, current_wait_time: estimateWaitTime(rides[3], 21) },
    { ride_id: rides[4]._id, people_in_queue: 16, current_wait_time: estimateWaitTime(rides[4], 16) },
    { ride_id: rides[5]._id, people_in_queue: 0, current_wait_time: 0 }
  ]);

  console.log("Seed data inserted successfully.");
  process.exit(0);
};

seed().catch((error) => {
  console.error("Seeding failed:", error.message);
  process.exit(1);
});
