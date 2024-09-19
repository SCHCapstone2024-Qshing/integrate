const express = require("express");
const cors = require("cors");
const app = express();
const port = 3000;

app.use(cors());

// 주요 도시의 좌표 데이터
const cities = {
  Seoul: { latitude: 37.5665, longitude: 126.978 },
  Busan: { latitude: 35.1796, longitude: 129.0756 },
  Incheon: { latitude: 37.4563, longitude: 126.7052 },
  Daegu: { latitude: 35.8714, longitude: 128.6014 },
  Daejeon: { latitude: 36.3504, longitude: 127.3845 },
  Gwangju: { latitude: 35.1595, longitude: 126.8526 },
  Suwon: { latitude: 37.2636, longitude: 127.0286 },
  Ulsan: { latitude: 35.5384, longitude: 129.3114 },
  Changwon: { latitude: 35.2285, longitude: 128.6811 },
  Seongnam: { latitude: 37.4201, longitude: 127.1265 },
  Goyang: { latitude: 37.6584, longitude: 126.832 },
  Yongin: { latitude: 37.2411, longitude: 127.1775 },
  Cheongju: { latitude: 36.6424, longitude: 127.489 },
  Jeonju: { latitude: 35.8242, longitude: 127.148 },
  Cheonan: { latitude: 36.8065, longitude: 127.1522 },
  Ansan: { latitude: 37.3219, longitude: 126.8309 },
  Jeju: { latitude: 33.4996, longitude: 126.5312 },
  Pohang: { latitude: 36.019, longitude: 129.3435 },
  Gimhae: { latitude: 35.2285, longitude: 128.8894 },
  Pyeongtaek: { latitude: 36.9907, longitude: 127.085 },
  Gangneung: { latitude: 37.7519, longitude: 128.8761 },
  Gumi: { latitude: 36.1195, longitude: 128.3446 },
  Iksan: { latitude: 35.9483, longitude: 126.9577 },
  Jinju: { latitude: 35.179, longitude: 128.1076 },
  Chuncheon: { latitude: 37.8813, longitude: 127.7298 },
};

// 모든 도시의 좌표를 반환하는 엔드포인트
app.get("/cities", (req, res) => {
  res.json(cities);
});

// 특정 도시의 좌표를 반환하는 엔드포인트
app.get("/cities/:city", (req, res) => {
  const city = req.params.city;
  const cityData = cities[city];

  if (cityData) {
    res.json(cityData);
  } else {
    res.status(404).json({ error: "City not found" });
  }
});

// 서버 실행
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
