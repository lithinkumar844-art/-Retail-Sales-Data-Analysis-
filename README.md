# Food Waste Detector (End-to-End Starter)

This repository now includes:

1. **Phase 1 (ML / Colab)**
   - `ml/train_colab.py`: Train MobileNetV2 on Fruits Fresh and Rotten dataset from Google Drive.
   - `ml/convert_to_tflite.py`: Convert `.h5` to optimized `.tflite` (FP16 + INT8).

2. **Phase 2–6 (Flutter app)**
   - Full Flutter starter in `FoodWasteDetector/` with:
     - Home screen + routes
     - Camera scan with `image_picker`
     - TFLite inference with `tflite_flutter`
     - Result screen (food type, freshness, confidence, recommendation)
     - SQLite history (`sqflite`)
     - Analytics dashboard (`fl_chart`)
     - Local notifications (`flutter_local_notifications`)
     - Firestore save service + Firebase Cloud Function trigger for rotten alerts

## Dataset and model training (Colab)

Use Kaggle dataset **Fruits Fresh and Rotten** and arrange folders in Drive:

- FreshApple
- FreshBanana
- FreshOrange
- RottenApple
- RottenBanana
- RottenOrange

Then run:

```python
!python ml/train_colab.py
```

Artifacts:
- `food_freshness_model.h5`
- `labels.txt`

## Convert model to TensorFlow Lite

```python
!python ml/convert_to_tflite.py
```

Artifacts:
- `food_freshness_model_fp16.tflite`
- `food_freshness_model.tflite` (INT8)

Copy `food_freshness_model.tflite` and `labels.txt` into:

- `FoodWasteDetector/assets/food_freshness_model.tflite`
- `FoodWasteDetector/assets/labels.txt`

## Flutter setup

```bash
cd FoodWasteDetector
flutter pub get
flutter run
```

### Firebase setup (Firestore + FCM)

1. Create Firebase project and add Android/iOS apps.
2. Download config files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS
3. Initialize Firebase in Flutter (CLI recommended):
   ```bash
   flutterfire configure
   ```
4. Enable Cloud Firestore.
5. Deploy Cloud Function in `FoodWasteDetector/firebase/functions/index.js`:
   ```bash
   cd firebase/functions
   npm install firebase-admin firebase-functions
   firebase deploy --only functions
   ```
6. Subscribe app clients to topic `food_alerts` for spoilage push alerts.

## Final integration notes

- Execution order matches your requested sequence:
  1) Train model → 2) Convert TFLite → 3) Flutter base → 4) Camera → 5) Inference → 6) History → 7) Dashboard → 8) Notifications.
- Bonus starter included: waste reduction tips page and Firestore integration hooks.
- For hackathon readiness, you can add auth and PDF export as next modules.
