# Proje Senaryosu ve Tablo Adayları (Kura #41)

## Hikâye
Bir kargo şirketi, depoya gelen paketlerin üzerindeki etiketleri kamerayla okuyor ve her okuma sonrasında bir dil modeline etiket metnini yapılandırılmış veriye çevirtiyor. Her çağrı kaydediliyor. Şirket, okuma maliyetinin ve gecikmesinin paket türüne göre nasıl değiştiğini izlemek istiyor.

## Ana Soru
Etiket okuma çağrılarının maliyeti ve gecikmesi, etiketin bulanık ya da eğik olmasıyla ilişkili mi?

## Hedef Kullanıcı
Kargo operasyon ve lojistik yönetim ekibi.

## Tablo Adayları ve Sütunlar
1. **packages**: id, package_type, weight_kg, recorded_at
2. **readings**: id, package_id, image_quality_score, read_succeeded
3. **llm_calls**: id, okuma_id, model_name, input_tokens, output_tokens, latency_ms, cost_usd

## YZ Bileşeni (Dönem Sonu Hedefi)
Görüntü kalitesi ile çıktı doğruluğu arasındaki ilişkiyi izleyen ve düşük kaliteli girdiyi model çağrısından önce eleyen bir kapı (gate) tablosu.

## Veri Kaynağı Adayları
* **Kaggle**: "receipt OCR", "invoice text", "package label" aramaları.
* **Hugging Face**: "OCR", "document extraction" aramaları.
