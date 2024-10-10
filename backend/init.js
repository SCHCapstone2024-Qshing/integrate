const express = require("express");
const cors = require("cors");
const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// 주요 도시의 좌표 데이터
const cities = [
  {
    latitude: 37.5665,
    longitude: 126.978,
    url: "https://en.wikipedia.org/wiki/Seoul",
    count: 0,
  },
  // {
  //   latitude: 35.1796,
  //   longitude: 129.0756,
  //   url: "https://en.wikipedia.org/wiki/Busan",
  // },
  // {
  //   latitude: 37.4563,
  //   longitude: 126.7052,
  //   url: "https://en.wikipedia.org/wiki/Incheon",
  // },
  // {
  //   latitude: 35.8714,
  //   longitude: 128.6014,
  //   url: "https://en.wikipedia.org/wiki/Daegu",
  // },
  // {
  //   latitude: 36.3504,
  //   longitude: 127.3845,
  //   url: "https://en.wikipedia.org/wiki/Daejeon",
  // },
  // {
  //   latitude: 35.1595,
  //   longitude: 126.8526,
  //   url: "https://en.wikipedia.org/wiki/Gwangju",
  // },
  // {
  //   latitude: 37.2636,
  //   longitude: 127.0286,
  //   url: "https://en.wikipedia.org/wiki/Suwon",
  // },
  // {
  //   latitude: 35.5384,
  //   longitude: 129.3114,
  //   url: "https://en.wikipedia.org/wiki/Ulsan",
  // },
  // {
  //   latitude: 35.2285,
  //   longitude: 128.6811,
  //   url: "https://en.wikipedia.org/wiki/Changwon",
  // },
  // {
  //   latitude: 37.4201,
  //   longitude: 127.1265,
  //   url: "https://en.wikipedia.org/wiki/Seongnam",
  // },
  // {
  //   latitude: 37.6584,
  //   longitude: 126.832,
  //   url: "https://en.wikipedia.org/wiki/Goyang",
  // },
  // {
  //   latitude: 37.2411,
  //   longitude: 127.1775,
  //   url: "https://en.wikipedia.org/wiki/Yongin",
  // },
  // {
  //   latitude: 36.6424,
  //   longitude: 127.489,
  //   url: "https://en.wikipedia.org/wiki/Cheongju",
  // },
  // {
  //   latitude: 35.8242,
  //   longitude: 127.148,
  //   url: "https://en.wikipedia.org/wiki/Jeonju",
  // },
  // {
  //   latitude: 36.8065,
  //   longitude: 127.1522,
  //   url: "https://en.wikipedia.org/wiki/Cheonan",
  // },
  // {
  //   latitude: 37.3219,
  //   longitude: 126.8309,
  //   url: "https://en.wikipedia.org/wiki/Ansan",
  // },
  // {
  //   latitude: 33.4996,
  //   longitude: 126.5312,
  //   url: "https://en.wikipedia.org/wiki/Jeju",
  // },
  // {
  //   latitude: 36.019,
  //   longitude: 129.3435,
  //   url: "https://en.wikipedia.org/wiki/Pohang",
  // },
  // {
  //   latitude: 35.2285,
  //   longitude: 128.8894,
  //   url: "https://en.wikipedia.org/wiki/Gimhae",
  // },
  // {
  //   latitude: 36.9907,
  //   longitude: 127.085,
  //   url: "https://en.wikipedia.org/wiki/Pyeongtaek",
  // },
  // {
  //   latitude: 37.7519,
  //   longitude: 128.8761,
  //   url: "https://en.wikipedia.org/wiki/Gangneung",
  // },
  // {
  //   latitude: 36.1195,
  //   longitude: 128.3446,
  //   url: "https://en.wikipedia.org/wiki/Gumi",
  // },
  // {
  //   latitude: 35.9483,
  //   longitude: 126.9577,
  //   url: "https://en.wikipedia.org/wiki/Iksan",
  // },
  // {
  //   latitude: 35.179,
  //   longitude: 128.1076,
  //   url: "https://en.wikipedia.org/wiki/Jinju",
  // },
  // {
  //   latitude: 37.8813,
  //   longitude: 127.7298,
  //   url: "https://en.wikipedia.org/wiki/Chuncheon",
  // },
];

// 모든 도시의 좌표를 반환하는 엔드포인트
app.get("/cities", (req, res) => {
  res.json(cities);
});

// 새로운 도시를 추가하거나 count 값을 증가시키는 POST 엔드포인트
app.post("/cities", (req, res) => {
  const { latitude, longitude, url } = req.body;

  // 입력값 검증
  if (!latitude || !longitude || !url) {
    return res
      .status(400)
      .json({ error: "Missing latitude, longitude, or url" });
  }

  // 동일한 URL이 이미 있는지 확인
  const existingCity = cities.find((city) => city.url === url);

  if (existingCity) {
    // URL이 이미 있으면 count 값을 증가시킴
    existingCity.count += 1;
    res.status(200).json({
      message: `Location with URL ${url} already exists, count incremented`,
      location: existingCity,
    });
  } else {
    // URL이 없으면 새로 추가
    const newCity = { latitude, longitude, url, count: 1 }; // 초기 count 값 1
    cities.push(newCity); // 배열에 객체 추가
    res.status(201).json({
      message: `Location with URL ${url} added successfully`,
      location: newCity,
    });
  }
});

// 서버 실행
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
