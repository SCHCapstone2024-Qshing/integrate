# Qshing 방지 스캐너

## main page


![alt text](https://github.com/SCHCapstone2024-Qshing/virustotal_api/blob/main/image/123.png)


메인 실행 코드는 lib/main.dart입니다.



## 사용한 패키지

mobile_scanner

pub.dev: https://pub.dev/packages/mobile_scanner

github: https://github.com/juliansteenbakker/mobile_scanner

## 추가로 설치가 필요한 패키지(더 있을 수도 있음)

image_picker: ^1.0.4

flutter_dotenv(버전 상관없음)

## 사전 작업

1. .env 파일을 최상위 폴더에 생성.

2. 안에 아래와 같이 작성
```
VIRUSTOTALAPI="API_KEY"
```
"" 기호는 필요 없고 API키는 가지고 있는 VIRUSTOTALAPI 값을 넣으면 됨.(띄어쓰기 x)
