const express = require("express");
const cors = require("cors");
// MongoDB 연결 (db.js 파일에서 MongoDB 연결을 처리)
require("./db");
// Cities 스키마 임포트
const Cities = require("./schema/cities");
const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// 두 좌표 간의 거리를 계산하는 함수 (단위: 미터)
function getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2) {
  const R = 6371; // 지구 반경 (단위: km)
  const dLat = deg2rad(lat2 - lat1); // 위도의 차이
  const dLon = deg2rad(lon2 - lon1); // 경도의 차이
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(deg2rad(lat1)) *
      Math.cos(deg2rad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distance = R * c * 50; // 거리 (단위: 미터)
  return distance;
}

function deg2rad(deg) {
  return deg * (Math.PI / 180);
}

// 예시: Cities 모델 사용 (GET 요청 처리 등)
app.get("/cities", async (req, res) => {
  try {
    console.log("GET Cities 요청 받음!\n");
    const cities = await Cities.find(); // MongoDB에서 데이터 조회
    console.log(cities);
    res.json(cities);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// 새로운 도시를 추가하거나 count 값을 증가시키는 POST 엔드포인트
app.post("/cities", async (req, res) => {
  const { latitude, longitude, url } = req.body;
  const proximityThreshold = 100; // 100미터 이내

  console.log(req.body);
  console.log("POST Cities 요청 받음!\n");

  // 입력값 검증
  if (!latitude || !longitude || !url) {
    return res
      .status(400)
      .json({ error: "Missing latitude, longitude, or url" });
  }

  try {
    // 모든 도시 데이터 조회
    const allCities = await Cities.find();

    // 동일한 URL이 있는지 확인
    const existingCity = allCities.find((city) => {
      // 동일한 URL이 있거나, 비슷한 위치에서 발견된 경우
      const distance = getDistanceFromLatLonInKm(
        latitude,
        longitude,
        city.latitude,
        city.longitude
      );
      return city.url === url && distance <= proximityThreshold;
    });

    if (existingCity) {
      // URL과 비슷한 위치가 이미 있으면 count 값을 증가시킴
      existingCity.count += 1;
      await existingCity.save(); // 변경 사항을 MongoDB에 저장
      res.status(200).json({
        message: `Location with URL ${url} or nearby location already exists, count incremented`,
        location: existingCity,
      });
    } else {
      // URL과 위치가 모두 없으면 새로 추가
      const newCity = new Cities({ latitude, longitude, url, count: 1 });
      await newCity.save(); // MongoDB에 새 데이터 저장
      res.status(201).json({
        message: `Location with URL ${url} added successfully`,
        location: newCity,
      });
    }
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// 서버 실행
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
