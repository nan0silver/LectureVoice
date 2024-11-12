# LectureVoice

- **Purpose**: Automatic lecture video commentary application
- **Target Audience**: Visually impaired students
- **Primary Functionality**:
  - Supports understanding of visual materials in lecture videos, including diagrams and text
  - Provides detailed audio commentary to convey visual content
- **Platform**: Developed for mobile devices
- **Goal**: To offer an independent and accessible learning experience for visually impaired students
- **Core Feature**: Generates audio descriptions for visual elements in videos, enhancing comprehension and engagement


## Overview

With the increase in online learning, especially since the COVID-19 pandemic, visually impaired students face challenges accessing visual information effectively. DiagramVoice addresses this issue by analyzing and describing visuals in lecture videos, including diagrams, which are essential in academic content but often overlooked in accessibility tools.

## Features

- **Voice-Activated Interface**
    - The app is fully voice-controlled, allowing visually impaired users to interact with the application using their voice.
- **Automatic Video Analysis**
    - DiagramVoice processes lecture videos by detecting screen transitions, extracting text and images, and generating descriptive commentary.
- **Diagram Commentary**
    - Using a custom-developed algorithm, the app interprets diagram images, identifying arrows, blocks, and text, to produce a meaningful narrative for visually impaired students.
- **Language Support**
    - Supports multiple languages for text recognition, including Korean, English, and Japanese.


## System Architecture

DiagramVoice is a mobile application developed in Dart using the Flutter framework. It integrates several backend technologies and APIs:

- **Server**
    - Developed with Flask and Python.
- **Text Recognition**
    - Utilizes Naver Clova OCR API for text extraction from images.
- **Image Captioning**
    - Integrates Google Cloud Image Captioning API for natural image captioning.
- **Audio Output**: Employs Google Cloud Text-to-Speech API to convert text commentary to audio for playback.



## Video Processing Workflow

1. **Scene Detection**
    - Uses PySceneDetect API to identify scene changes in lecture videos, capturing images at each transition.
2. **Text Extraction**
    - Performs OCR on captured images to detect and extract text, storing it with spatial coordinates.
3. **Diagram Detection**
    - Identifies and distinguishes diagrams from other visuals using a custom algorithm, enabling detailed diagram narration.
4. **Commentary Generation**
    - Compiles extracted text and image descriptions into a single text file that is synchronized with the video playback.

## Diagram Commentary Algorithm

The algorithm developed for DiagramVoice processes diagram images by detecting shapes (arrows and rectangles) and generating structured commentary. Key steps include:

- **Contour Detection**
    - Identifies edges in diagrams and classifies them as arrows or blocks.
- **Text Association**
    - Links text to diagram elements, providing context and connecting relationships between blocks and arrows.
- **Narrative Generation**
    - Constructs a coherent description of the diagram, enabling visually impaired users to understand complex visual information.

## Evaluation

DiagramVoice was evaluated for usability and satisfaction, showing a significant improvement in user comprehension compared to standard image captioning methods. Feedback from visually impaired students highlighted the clarity and usefulness of the detailed commentary.

## Usage

To use DiagramVoice:
1. Launch the app and select a lecture video from your device’s gallery.
2. Allow the app to process the video, generating commentary for each scene.
3. Play the video to hear audio descriptions of visuals at each transition.

## Installation

DiagramVoice is compatible with Android and iOS platforms. To install, follow these instructions:

1. Clone the repository: `git clone https://github.com/nan0silver/DiagramAnalysisGenerationAlgorithm`
2. Follow the setup instructions for Flutter and Flask (provided in the repository) to configure the backend server and mobile app.

## Dependencies

- **Dart & Flutter**: [https://flutter.dev/](https://flutter.dev/)
- **Python & Flask**: [https://www.python.org/](https://www.python.org/), [https://flask.palletsprojects.com/](https://flask.palletsprojects.com/)
- **PySceneDetect API**: [https://pyscenedetect.readthedocs.io/](https://pyscenedetect.readthedocs.io/)
- **Naver Clova OCR API**: [https://www.ncloud.com/product/aiService/ocr](https://www.ncloud.com/product/aiService/ocr)
- **Google Cloud Text-to-Speech API**: [https://cloud.google.com/text-to-speech](https://cloud.google.com/text-to-speech)


---

For more information, please refer to the full documentation in the [ICICT 2024 Conference Paper](https://doi.org/10.1007/978-981-97-3559-4_31).

