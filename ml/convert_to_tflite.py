"""Convert Keras .h5 model to TensorFlow Lite with quantization."""

import tensorflow as tf

H5_MODEL_PATH = "food_freshness_model.h5"
TFLITE_FP16_PATH = "food_freshness_model_fp16.tflite"
TFLITE_INT8_PATH = "food_freshness_model.tflite"

# Load Keras model
model = tf.keras.models.load_model(H5_MODEL_PATH)
print("Loaded:", H5_MODEL_PATH)

# ---------- FP16 quantization (easy, robust) ----------
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]
tflite_fp16 = converter.convert()

with open(TFLITE_FP16_PATH, "wb") as f:
    f.write(tflite_fp16)
print("Saved:", TFLITE_FP16_PATH)


# ---------- Full INT8 quantization ----------
def representative_data_gen():
    # Replace with a small sample from your real training images
    for _ in range(100):
        sample = tf.random.uniform((1, 224, 224, 3), minval=0, maxval=255, dtype=tf.float32)
        yield [sample]

converter_int8 = tf.lite.TFLiteConverter.from_keras_model(model)
converter_int8.optimizations = [tf.lite.Optimize.DEFAULT]
converter_int8.representative_dataset = representative_data_gen
converter_int8.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter_int8.inference_input_type = tf.uint8
converter_int8.inference_output_type = tf.uint8

tflite_int8 = converter_int8.convert()
with open(TFLITE_INT8_PATH, "wb") as f:
    f.write(tflite_int8)
print("Saved:", TFLITE_INT8_PATH)

# Size report
import os
print("FP16 size (KB):", os.path.getsize(TFLITE_FP16_PATH) / 1024)
print("INT8 size (KB):", os.path.getsize(TFLITE_INT8_PATH) / 1024)
