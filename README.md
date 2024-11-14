# 🎙️ LectureVoice

### 📚 **Purpose**: Automatic lecture video commentary application  
### 👥 **Target Audience**: Visually impaired students

**LectureVoice**는 시각 장애 학생들이 강의 영상을 보다 쉽게 이해할 수 있도록 **음성 해설을 자동으로 생성**하여 제공하는 모바일 애플리케이션입니다.

## 🌟 주요 기능
- **비디오 분석 및 해설 생성**
  - 강의 영상의 다이어그램과 텍스트를 인식하고, 상세한 오디오 해설을 제공합니다.
- **플랫폼**
  - 모바일 기기에서 사용할 수 있도록 설계되었습니다.
- **목표**
  - 시각 장애 학생들에게 독립적이고 접근 가능한 학습 경험을 제공합니다.
- **핵심 기능**
  - 비디오의 시각 요소에 대한 오디오 설명을 자동 생성하여 이해도를 높입니다.

---

## 📖 Overview

COVID-19 팬데믹 이후 온라인 학습이 증가하면서, 시각 장애 학생들은 시각적 정보 접근에 어려움을 겪고 있습니다. **LectureVoice**는 강의 영상의 다이어그램과 시각 자료를 분석하고 설명하여 이러한 문제를 해결하고자 합니다.

---

## 🔍 주요 기능

### 1️⃣ **음성 활성화 인터페이스**
- 완전한 음성 제어로 시각 장애 사용자가 앱과 상호작용할 수 있습니다.

### 2️⃣ **자동 비디오 분석**
- **LectureVoice**는 강의 비디오의 화면 전환을 감지하고, 텍스트와 이미지를 추출하여 설명을 생성합니다.

### 3️⃣ **시각적 자료 해설**
- 텍스트, 그림, 표, 다이어그램 등 시각적 자료의 유형에 맞는 해설 방법을 선택하여 정확한 이해를 돕는 음성 해설을 생성합니다.

### 4️⃣ **다이어그램 해설**
- 맞춤형 알고리즘을 사용하여 다이어그램의 화살표, 블록, 텍스트를 분석하고, 의미 있는 내러티브를 제공합니다.


---

## 🛠️ 시스템 아키텍처

LectureVoice는 **Dart**와 **Flutter** 프레임워크로 개발된 모바일 애플리케이션입니다. 다양한 백엔드 기술과 API가 통합되어 있습니다:

- **서버**: Flask와 Python으로 개발
- **텍스트 인식**: Naver Clova OCR API 사용
- **이미지 캡셔닝**: Google Cloud Image Captioning API 사용
- **오디오 출력**: Google Cloud Text-to-Speech API 사용

---

## 📺 비디오 처리 흐름

1. **장면 감지**
   - PySceneDetect API를 사용하여 장면 전환을 감지하고, 각 전환 지점에서 이미지를 캡처합니다.
2. **텍스트 추출**
   - OCR을 통해 캡처된 이미지에서 텍스트를 추출하고, 공간 좌표와 함께 저장합니다.
3. **다이어그램 분석**
   - 맞춤형 알고리즘을 사용해 다이어그램을 분석하고, 상세한 설명을 생성합니다.
4. **해설 생성**
   - 추출된 텍스트와 이미지 설명을 종합하여 비디오 재생과 동기화된 텍스트 파일을 생성합니다.

---

## 📝 다이어그램 해설 알고리즘

LectureVoice의 알고리즘은 다이어그램 이미지에서 **모양(화살표, 사각형)**을 감지하고, 구조화된 설명을 생성합니다:

- **윤곽선 감지**: 다이어그램의 가장자리를 식별하고, 이를 화살표나 블록으로 분류합니다.
- **텍스트 연관성 분석**: 텍스트를 다이어그램 요소와 연결하여 관계를 설명합니다.
- **내러티브 생성**: 다이어그램에 대한 일관된 설명을 생성하여 시각 장애 사용자가 복잡한 시각 정보를 이해할 수 있도록 돕습니다.

---

## 📊 평가

**LectureVoice**는 사용성 및 만족도 평가에서 표준 이미지 캡셔닝 방식보다 높은 이해도를 보였습니다. 시각 장애 학생들의 피드백은 해설의 명확성과 유용성을 강조했습니다.

---

## 🚀 사용 방법

1. 앱을 실행하고 기기 갤러리에서 강의 비디오를 선택하세요.
2. 앱이 비디오를 처리하고, 각 장면에 대한 해설을 생성합니다.
3. 비디오를 재생하여 장면 전환마다 오디오 설명을 들을 수 있습니다.

---

## 📥 설치 방법

LectureVoice는 Android 및 iOS 플랫폼에서 사용할 수 있습니다. 설치 방법은 다음과 같습니다:

- 레포지토리 클론:
   ```bash
   git clone https://github.com/nan0silver/DiagramAnalysisGenerationAlgorithm


---

### 📦 의존성

- **Dart & Flutter**: [flutter.dev](https://flutter.dev/)
- **Python & Flask**: [python.org](https://www.python.org/), [flask.palletsprojects.com](https://flask.palletsprojects.com/)
- **PySceneDetect API**: [pyscenedetect.readthedocs.io](https://pyscenedetect.readthedocs.io/)
- **Naver Clova OCR API**: [ncloud.com/product/aiService/ocr](https://www.ncloud.com/product/aiService/ocr)
- **Google Cloud Text-to-Speech API**: [cloud.google.com/text-to-speech](https://cloud.google.com/text-to-speech)

---

### 📄 참고 자료
- 자세한 내용은 **[ICICT 2024 Conference Paper](https://doi.org/10.1007/978-981-97-3559-4_31)**를 참고하세요.


