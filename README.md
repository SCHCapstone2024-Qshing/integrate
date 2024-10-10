# Qshing 방지 스캐너

## main page

![alt text](https://github.com/SCHCapstone2024-Qshing/virustotal_api/blob/main/image/123.png)
**메인 실행 코드는 lib/main.dart입니다.**

## 사용한 패키지

mobile_scanner
pub.dev: https://pub.dev/packages/mobile_scanner
github: https://github.com/juliansteenbakker/mobile_scanner

## 추가로 설치가 필요한 패키지(더 있을 수도 있음)

image_picker: ^1.0.4
flutter_dotenv(버전 상관없음)
intl: ^0.17.0
geolocator: ^9.0.0
google_maps_flutter: ^2.6.1

---

# 사전 작업

## 1. Virustotal API

1. .env 파일을 최상위 폴더에 생성.
2. 안에 아래와 같이 작성

```
VIRUSTOTALAPI=API_KEY
```

**"" 기호는 필요 없고 API키는 가지고 있는 VIRUSTOTALAPI 값을 넣으면 됨.(띄어쓰기 x)**

---

## 2. Google Map API

![alt text](https://github.com/SCHCapstone2024-Qshing/virustotal_api/blob/main/image/map_image.jpg)

1. /android/local.properties 파일 수정

```
googleMapsApiKey=API_KEY
```

**Virustotal API와 마찬가지로 가지고 있는 키로 "" 없이, 띄어쓰기 없이 넣기**

---

## 3. Backend

### 3.1 Nodejs 설치 (v20.11.0)

```
https://nodejs.org/en
```

### 3.2 MongoDB 설치 (Mongosh)

mongoDB Community
mongosh 2.1.4

```
https://www.mongodb.com/ko-kr/docs/manual/introduction/
https://www.mongodb.com/ko-kr/docs/mongodb-shell/
```

### 3.3 cd /backend

**패키지 설치**

```
npm i
```

**백엔드 서버 올리기**

```
npm run dev:server
```

✅ **MongoDB가 제대로 실행되어 올라가있는지 확인 후 실행**
✅ **DB는 서버 실행시 자동으로 생성 됨**

---

# Patch Note

## 2024-10-10

#### 1. DB 저장 구현

- db.js
- citiesDB
  - cities

#### 2. backend 폴더 리팩토링

- schema/cities.js

#### 3. QR 스캔, 갤러리 스캔시 API POST

- 위치정보, url 전송
- 제보수에 따른 원 크기 조절
- 비슷한 위치에서 제보시 제보수만 카운트
- Marker 눌렀을 때 정보 출력 (url, time, count)

#### 4. API 호출 리팩토링

- lib/API/api.dart
