// MongoDB 연결
const mongoose = require("mongoose"); // Mongoose 임포트

mongoose
  .connect("mongodb://localhost:27017/citiesDB")
  .then(() => console.log("MongoDB connected!"))
  .catch((err) => console.log("MongoDB connection error:", err));
