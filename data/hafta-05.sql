-- Hafta 5 Analiz Sorguları - Kura #41 (Lojistik ve Teslimat - Görüntü İşleyen Kamera & LLM Çağrıları)

-- -----------------------------------------------------------------------------
-- Sorgu 1: Paket türüne göre çağrı sayısı ve toplam maliyet
-- Bu sorgu, her bir paket türü (Koli, Zarf, Kutu vb.) için kaç adet LLM çağrısı 
-- yapıldığını ve şirket bütçesinden bu çağrılar için toplam ne kadar (USD) 
-- harcandığını hesaplar. GROUP BY ve SUM fonksiyonları kullanılmıştır.
-- -----------------------------------------------------------------------------
SELECT 
    p.package_type,
    COUNT(c.id) AS toplam_cagri_sayisi,
    ROUND(SUM(c.cost_usd)::numeric, 4) AS toplam_maliyet_usd
FROM packages p
JOIN readings r ON p.id = r.package_id
JOIN llm_calls c ON r.id = c.okuma_id
GROUP BY p.package_type
ORDER BY toplam_maliyet_usd DESC;


-- -----------------------------------------------------------------------------
-- Sorgu 2: Kalite skoru NULL olan okumaların sayısı ve başarı oranı
-- Kamera kalitesinin ölçülemediği (image_quality_score IS NULL) durumların 
-- toplam okumalar içindeki oranını ve bu durumun okuma başarısına etkisini 
-- COUNT(*) ile COUNT(image_quality_score) farkını kullanarak inceler.
-- -----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS toplam_okuma_sayisi,
    COUNT(image_quality_score) AS skoru_olan_okuma_sayisi,
    (COUNT(*) - COUNT(image_quality_score)) AS kalite_skoru_null_sayisi,
    ROUND(
        (CAST(COUNT(*) - COUNT(image_quality_score) AS decimal) / COUNT(*)) * 100, 2
    ) AS null_orani_yuzde
FROM readings;


-- -----------------------------------------------------------------------------
-- Sorgu 3: Her paket türünde en az 30 çağrısı olan model adları
-- Farklı LLM modellerinin (gpt-4o, claude-3-haiku vb.) hangi paket türlerinde 
-- yoğunlaştığını ve istatistiki olarak anlamlı örneklem (en az 30 çağrı) 
-- sunan grupları HAVING koşulu ile filtreleyerek listeler.
-- -----------------------------------------------------------------------------
SELECT 
    p.package_type,
    c.model_name,
    COUNT(c.id) AS cagri_sayisi
FROM packages p
JOIN readings r ON p.id = r.package_id
JOIN llm_calls c ON r.id = c.okuma_id
GROUP BY p.package_type, c.model_name
HAVING COUNT(c.id) >= 30
ORDER BY p.package_type, cagri_sayisi DESC;


-- -----------------------------------------------------------------------------
-- Sorgu 4: Kalite skorunu sınıflandıran CASE WHEN ve ortalama gecikme
-- Görüntü kalitesi skorlarını 'low' (1-2), 'medium' (3) ve 'high' (4-5) olarak 
-- kategorilere ayırarak, her kalite seviyesinin model yanıt gecikmesine 
-- (latency_ms) etkisini ortalama bazda karşılaştırır.
-- -----------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN r.image_quality_score <= 2 THEN 'low'
        WHEN r.image_quality_score = 3 THEN 'medium'
        WHEN r.image_quality_score >= 4 THEN 'high'
        ELSE 'bilinmiyor/null'
    END AS kalite_kategorisi,
    COUNT(c.id) AS kayit_sayisi,
    ROUND(AVG(c.latency_ms), 2) AS ortalama_gecikme_ms
FROM readings r
JOIN llm_calls c ON r.id = c.okuma_id
GROUP BY kalite_kategorisi
ORDER BY ortalama_gecikme_ms DESC;


-- -----------------------------------------------------------------------------
-- Sorgu 5: Haftalık çağrı maliyeti toplamı ve başarısız okuma oranı trendi
-- Zaman damgasına göre (date_trunc) haftalık bazda toplam LLM maliyetlerini 
-- ve sistemdeki başarısız okuma oranlarını yan yana izleyerek operasyonel 
-- maliyet trendinin zamanla nasıl değiştiğini analiz eder.
-- -----------------------------------------------------------------------------
SELECT 
    date_trunc('week', p.recorded_at) AS hafta,
    COUNT(c.id) AS toplam_cagri,
    ROUND(SUM(c.cost_usd)::numeric, 4) AS haftalik_toplam_maliyet,
    ROUND(
        (SUM(CASE WHEN r.read_succeeded = FALSE THEN 1 ELSE 0 END)::decimal / COUNT(c.id)) * 100, 2
    ) AS basarisiz_okuma_orani_yuzde
FROM packages p
JOIN readings r ON p.id = r.package_id
JOIN llm_calls c ON r.id = c.okuma_id
GROUP BY hafta
ORDER BY hafta ASC;
