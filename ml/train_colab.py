"""Google Colab training script for Fruits Fresh and Rotten dataset.

Steps:
1. Mount Google Drive
2. Load dataset from Drive with expected folder names:
   FreshApple, FreshBanana, FreshOrange,
   RottenApple, RottenBanana, RottenOrange
3. Build/train MobileNetV2 transfer learning model
4. Plot accuracy/loss curves
5. Save model as food_freshness_model.h5
"""

import os
import pathlib

import matplotlib.pyplot as plt
import tensorflow as tf
from tensorflow.keras import layers, models

# ---------- Colab setup ----------
# In Colab, uncomment these lines:
# from google.colab import drive
# drive.mount('/content/drive')

DATASET_DIR = "/content/drive/MyDrive/fruits_fresh_and_rotten"  # update path if needed
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
SEED = 42
EPOCHS = 12

if not os.path.isdir(DATASET_DIR):
    raise FileNotFoundError(
        f"Dataset path not found: {DATASET_DIR}. "
        "Put your Kaggle dataset folders inside Google Drive and update DATASET_DIR."
    )

class_names_expected = {
    "FreshApple",
    "FreshBanana",
    "FreshOrange",
    "RottenApple",
    "RottenBanana",
    "RottenOrange",
}
found = {p.name for p in pathlib.Path(DATASET_DIR).iterdir() if p.is_dir()}
missing = class_names_expected - found
if missing:
    raise ValueError(f"Missing class folders: {missing}")

train_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_DIR,
    validation_split=0.2,
    subset="training",
    seed=SEED,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
)

val_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_DIR,
    validation_split=0.2,
    subset="validation",
    seed=SEED,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
)

class_names = train_ds.class_names
num_classes = len(class_names)
print("Classes:", class_names)

AUTOTUNE = tf.data.AUTOTUNE
train_ds = train_ds.cache().shuffle(1000).prefetch(buffer_size=AUTOTUNE)
val_ds = val_ds.cache().prefetch(buffer_size=AUTOTUNE)

# ---------- Model ----------
base_model = tf.keras.applications.MobileNetV2(
    input_shape=(224, 224, 3),
    include_top=False,
    weights="imagenet",
)
base_model.trainable = False

data_augmentation = tf.keras.Sequential(
    [
        layers.RandomFlip("horizontal"),
        layers.RandomRotation(0.08),
        layers.RandomZoom(0.1),
    ]
)

inputs = layers.Input(shape=(224, 224, 3))
x = data_augmentation(inputs)
x = tf.keras.applications.mobilenet_v2.preprocess_input(x)
x = base_model(x, training=False)
x = layers.GlobalAveragePooling2D()(x)
x = layers.Dropout(0.2)(x)
outputs = layers.Dense(num_classes, activation="softmax")(x)

model = models.Model(inputs, outputs)
model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy"],
)

model.summary()

callbacks = [
    tf.keras.callbacks.EarlyStopping(monitor="val_loss", patience=3, restore_best_weights=True),
    tf.keras.callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.2, patience=2),
]

history = model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS, callbacks=callbacks)

# ---------- Plot metrics ----------
acc = history.history["accuracy"]
val_acc = history.history["val_accuracy"]
loss = history.history["loss"]
val_loss = history.history["val_loss"]

plt.figure(figsize=(12, 4))
plt.subplot(1, 2, 1)
plt.plot(acc, label="Train Accuracy")
plt.plot(val_acc, label="Val Accuracy")
plt.title("Accuracy")
plt.xlabel("Epoch")
plt.ylabel("Accuracy")
plt.legend()

plt.subplot(1, 2, 2)
plt.plot(loss, label="Train Loss")
plt.plot(val_loss, label="Val Loss")
plt.title("Loss")
plt.xlabel("Epoch")
plt.ylabel("Loss")
plt.legend()
plt.tight_layout()
plt.show()

# ---------- Save model ----------
model.save("food_freshness_model.h5")
print("Saved model: food_freshness_model.h5")

# Optional: persist label map for Flutter app
with open("labels.txt", "w", encoding="utf-8") as f:
    for label in class_names:
        f.write(f"{label}\n")
print("Saved labels: labels.txt")
