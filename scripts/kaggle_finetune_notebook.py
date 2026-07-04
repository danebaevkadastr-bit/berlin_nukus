# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  KAGGLE NOTEBOOK - Nemis tili o'rgatuvchi AI fine-tune                      ║
# ║  Model: Qwen2.5-7B-Instruct (4-bit)                                        ║
# ║  Texnologiya: unsloth + QLoRA + SFTTrainer                                 ║
# ║                                                                             ║
# ║  Kaggle'da: New Notebook -> GPU T4 x2 tanlang -> shu kodni joylashtiring   ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ── 1. KUTUBXONALARNI O'RNATISH ──────────────────────────────────────────────
# Kaggle'da birinchi marta ~3-5 daqiqa ketadi
# O'rnatgandan keyin Runtime -> Restart Session qiling!

!pip install -U bitsandbytes unsloth trl datasets -q

# ── 2. MODELNI YUKLASH (4-bit quantized) ─────────────────────────────────────

from unsloth import FastLanguageModel
import torch

model, tokenizer = FastLanguageModel.from_pretrained(
    # Qwen2.5-7B — turk tili oilasi, nemis, rus uchun eng mos 7B model
    model_name="unsloth/Qwen2.5-7B-Instruct-bnb-4bit",
    max_seq_length=2048,
    dtype=None,          # auto-detect
    load_in_4bit=True,   # 16GB GPU uchun majburiy
)

print("Model yuklandi!")


# ── 3. LoRA ADAPTER QO'SHISH ─────────────────────────────────────────────────

model = FastLanguageModel.get_peft_model(
    model,
    r=64,                # LoRA rank — kattaroq = ko'proq o'rganadi, ko'proq xotira
    lora_alpha=16,
    lora_dropout=0,
    target_modules=[     # Qwen2.5 uchun barcha muhim qatlamlar
        "q_proj", "k_proj", "v_proj", "o_proj",
        "gate_proj", "up_proj", "down_proj",
    ],
    bias="none",
    use_gradient_checkpointing="unsloth",  # xotirani 60% tejaydi
)

print("LoRA adapter qo'shildi!")

# ── 4. DATASET YUKLASH ───────────────────────────────────────────────────────
# training_data.jsonl faylini Kaggle'ga yuklang:
#   - Input -> Add Data -> Upload -> training_data.jsonl
#   - Yoki notebook'ga to'g'ridan-to'g'ri ko'chirish

from datasets import load_dataset

# Kaggle'da fayl yo'li (yuklaganingizga qarab o'zgartiring):
DATASET_PATH = "/kaggle/input/datasets/musakadastr/dataset/training_data.jsonl"
# Agar notebook'ga to'g'ridan-to'g'ri yozgan bo'lsangiz:
# DATASET_PATH = "training_data.jsonl"

dataset = load_dataset("json", data_files=DATASET_PATH, split="train")
print(f"Dataset yuklandi: {len(dataset)} ta misol")


# ── 5. DATASET FORMATLASH ────────────────────────────────────────────────────
# Qwen2.5 chat template'iga moslab formatlash

def format_chat(example):
    """JSONL dagi messages ni Qwen chat formatiga o'giradi."""
    text = tokenizer.apply_chat_template(
        example["messages"],
        tokenize=False,
        add_generation_prompt=False,
    )
    return {"text": text}

dataset = dataset.map(format_chat)
print("Dataset formatlandi!")
print(f"Namuna:\n{dataset[0]['text'][:500]}")

# ── 6. TRAINING (FINE-TUNE) ──────────────────────────────────────────────────

from trl import SFTTrainer, SFTConfig

trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    train_dataset=dataset,
    args=SFTConfig(
        output_dir="./outputs",
        per_device_train_batch_size=2,       # T4 16GB uchun 2 yetarli
        gradient_accumulation_steps=4,       # effective batch = 8
        num_train_epochs=3,                  # 3 epoch — 500+ misol uchun yetarli
        learning_rate=2e-4,
        warmup_steps=10,
        max_seq_length=2048,
        dataset_text_field="text",
        fp16=not torch.cuda.is_bf16_supported(),
        bf16=torch.cuda.is_bf16_supported(),
        logging_steps=5,
        save_strategy="epoch",
        seed=42,
    ),
)

print("Training boshlanmoqda...")
stats = trainer.train()
print(f"Training tugadi! Loss: {stats.training_loss:.4f}")


# ── 7. MODELNI SAQLASH ───────────────────────────────────────────────────────
# LoRA adapterlarni saqlash (kichik hajm, ~200-400MB)

model.save_pretrained("berlin_nukus_lora")
tokenizer.save_pretrained("berlin_nukus_lora")
print("LoRA adapter saqlandi: berlin_nukus_lora/")

# To'liq model (merged) saqlash — kattaroq lekin mustaqil ishlatish uchun:
# model.save_pretrained_merged("berlin_nukus_merged", tokenizer, save_method="merged_16bit")

# ── 8. SINAB KO'RISH ─────────────────────────────────────────────────────────

FastLanguageModel.for_inference(model)

test_messages = [
    {"role": "system", "content": "Sen nemis tili o'qituvchisisan. Daraja: A1. Mavzu: Familie. O'zbek tilida tushuntir. Emoji ishlatma. Har javobda 1 ta savol ber."},
    {"role": "user", "content": "Ich habe zwei Brueder"},
]

inputs = tokenizer.apply_chat_template(
    test_messages,
    tokenize=True,
    add_generation_prompt=True,
    return_tensors="pt",
).to("cuda")

outputs = model.generate(
    input_ids=inputs,
    max_new_tokens=256,
    temperature=0.7,
    do_sample=True,
)

response = tokenizer.decode(outputs[0][inputs.shape[-1]:], skip_special_tokens=True)
print(f"\n{'='*60}")
print(f"TEST JAVOB:\n{response}")
print(f"{'='*60}")

# ── 9. HUGGING FACE'GA YUKLASH (ixtiyoriy) ──────────────────────────────────
# Agar modelni boshqa joyda ishlatmoqchi bo'lsangiz:
#
# from huggingface_hub import login
# login(token="hf_YOUR_TOKEN")
# model.push_to_hub_merged("username/berlin-nukus-german-teacher", tokenizer)

print("\nTayyor! Keyingi qadamlar:")
print("1. 'berlin_nukus_lora' papkani yuklab oling (Output tab)")
print("2. Misollar sonini 500+ ga ko'paytiring")
print("3. Qayta fine-tune qiling")
print("4. Ilovaga ulang (vLLM/Ollama orqali)")
