const mongoose = require("mongoose"); // Mongoose 임포트

// City 스키마 정의
const citySchema = new mongoose.Schema({
  latitude: Number,
  longitude: Number,
  url: String,
  count: { type: Number, default: 1 },
});

// Cities 모델 생성 및 내보내기
module.exports = mongoose.model("Cities", citySchema);
