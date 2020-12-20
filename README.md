# MotionDataCollector

![image](https://user-images.githubusercontent.com/21030956/102707561-84e9ff00-42df-11eb-90d1-57b81fe6d148.png)

사용자 모션에 따라 발생하는 센서값들을 수집하여 csv 포맷으로 저장합니다. 다음은 수집하는 센서 데이터 목록입니다.

- attitude.roll
- attitude.pitch
- attitude.yaw
- gravity.x
- gravity.y
- gravity.z
- rotationRate.x
- rotationRate.y
- rotationRate.z
- userAcceleration.x
- userAcceleration.y
- userAcceleration.z

### How To Run

- 시뮬레이터에서는 동작이 안됩니다. 반드시 실제 디바이스에서 빌드하여 사용하세요.
- **파일 앱 - 나의 iPhone - MotionDataCollector** 에서 수집한 csv 파일을 확인할 수 있습니다.
- 상태(running 혹은 standing)에 따라서 수집하는 데이터를 구분할 수 있도록 하위 디렉토리로 구분했습니다.

