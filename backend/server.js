const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const connectDB = require("./config/db");

dotenv.config();
connectDB();

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/", require("./routes/authRoutes"));
app.use("/rides", require("./routes/rideRoutes"));
app.use("/tickets", require("./routes/ticketRoutes"));
app.use("/payments", require("./routes/paymentRoutes"));
app.use("/feedback", require("./routes/feedbackRoutes"));
app.use("/queue", require("./routes/queueRoutes"));
app.use("/staff", require("./routes/staffRoutes"));
app.use("/maintenance", require("./routes/maintenanceRoutes"));
app.use("/analytics", require("./routes/analyticsRoutes"));

app.get("/health", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

const PORT = process.env.PORT || 5000;
const HOST = process.env.HOST || "0.0.0.0";

app.listen(PORT, HOST, () => {
  console.log(`Server running on http://${HOST}:${PORT}`);
});
