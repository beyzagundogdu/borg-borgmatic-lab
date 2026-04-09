## Borg + Borgmatic Backup & Disaster Recovery Lab

Bu projede, gerçek bir sistemde karşılaşılabilecek veri kaybı senaryolarına karşı **uçtan uca Backup & Disaster Recovery (DR)** süreci kurulmuş ve test edilmiştir.

Amaç:  
Bir sistemde veri kaybı yaşandığında **veriyi nasıl güvenli şekilde geri getirebiliriz?** sorusuna pratik bir çözüm üretmek.


### Proje Kapsamı (Scope)

Bu çalışma kapsamında aşağıdaki senaryolar uçtan uca uygulanmıştır:
	•	PostgreSQL veritabanı yedekleme ve geri yükleme
	•	MySQL veritabanı yedekleme ve geri yükleme
	•	Dosya sistemi (filesystem) yedekleme ve geri yükleme
	•	Borg ile deduplicated (tekrarsız) backup
	•	Compression (sıkıştırma) ve Encryption (şifreleme) kullanımı
	•	Borgmatic ile merkezi ve otomatik backup yönetimi
	•	Retention (saklama) politikalarının uygulanması
	•	Manuel backup tetikleme ve doğrulama
	•	Backup’tan veri geri yükleme (restore) senaryoları


### Mimari Diyagram (Architecture Diagram)

┌──────────────────────────────────────────────────────────────┐
│                      Kaynak Sistemler                        │
│                                                              │
│  ┌─────────────────┐   ┌─────────────────┐   ┌────────────┐  │
│  │   PostgreSQL    │   │      MySQL      │   │ Dosya Sist.│  │
│  │ logical backup  │   │ logical backup  │   │ /home,/etc │  │
│  └────────┬────────┘   └────────┬────────┘   └─────┬──────┘  │
└───────────┼─────────────────────┼──────────────────┼────────-┘
            │                     │                  │
            ▼                     ▼                  ▼
┌──────────────────────────────────────────────────────────────┐
│                         Borgmatic                            │
│                                                              │
│ - Merkezi backup orkestrasyonu                               │
│ - Konfigürasyon tabanlı çalışma                              │
│ - Veritabanı dump entegrasyonu                               │
│ - Retention (saklama) politikası yönetimi                    │
│ - Manuel / otomatik backup süreci                            │
└───────────────────────────────┬──────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────┐
│                            Borg                              │
│                                                              │
│ - Deduplication (tekrarsız saklama)                          │
│ - Compression (sıkıştırma)                                   │
│ - Encryption (şifreleme)                                     │
│ - Snapshot tabanlı veri saklama                              │
└───────────────────────────────┬──────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────┐
│                     Backup Repository                        │
│                  /var/backups/borg-repo                      │
│                                                              │
│ Snapshot arşivleri + metadata + şifreli yedek veriler        │
└───────────────────────────────┬──────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────┐
│                     Geri Yükleme Süreci                      │
│                                                              │
│ borg extract                                                 │
│   ├── PostgreSQL → pg_restore                                │
│   ├── MySQL      → mysql / SOURCE                            │
│   └── Dosya Sistemi → dosya/klasör geri yükleme              │
└──────────────────────────────────────────────────────────────┘