 Borg + Borgmatic Kurulumu ve Yapılandırması

1) Borg kurulumu

Repository oluşturarak başladım:

```bash sudo apt install borgbackup
sudo mkdir -p /var/backups/borg-repo
sudo borg init --encryption=repokey /var/backups/borg-repo ```

Bu repository tüm PostgreSQL, MySQL ve filesystem yedeklerinin saklandığı yer oldu.


2) Borgmatic kurulumu

```bash
sudo apt install borgmatic
sudo borgmatic config generate --destination /etc/borgmatic/config.yaml
```

Default bir config dosyası oluştu fakat ben içeriğini silerek config.yaml dosyasını düzenledim ve:
	•hangi klasörlerin yedekleneceğini,
	•PostgreSQL dump’ının nasıl alınacağını,
	•MySQL dump’ının nasıl alınacağını,
	•Borg repository yolunu,
	•yedeğin şifreleme anahtarını,
	•otomatik çalıştırma ayarlarını
tanımladım.

Sonrasında test amaçlı manuel backup aldım:

```bash
sudo borgmatic --verbosity 1
```

PostgreSQL Üzerinde Yaptıklarım
	•Önce örnek bir veritabanı oluşturdum
	•Borgmatic ile otomatik dump + backup çalışan bir yapı kurdum
	•Sonra veritabanını bilerek sildim
	•Arşivden çıkarıp pg_restore ile geri yükledim
	•Bu işlemleri yaparken zaman zaman dosya izinleri, socket hataları ve path sorunları gibi gerçek hayat hatalarıyla uğraştım ve çözdüm

Arşivden yedeği çıkarmak:

```bash
sudo borg extract /var/backups/borg-repo::<snapshot_adi> root/.borgmatic/postgresql_databases/localhost/pg_demo
```

Restore işlemi:

```bash
sudo -u postgres pg_restore -d pg_demo $HOME/root/.borgmatic/postgresql_databases/localhost/pg_demo

```

Kontrol:

```sql
SELECT * FROM <table_name>;
```

MySQL Üzerinde Yaptıklarım
	•MySQL dump’larının otomatik olarak yedeklenmesini sağladım
	•Veritabanını tamamen drop edip yedekten tekrar attım
	•Dump dosyasının farklı bir dizine çıkması, izin hataları gibi gerçek senaryolar yaşadım ve çözüm yolları bularak başarıyla restore ettim

Arşivden dump dosyasını çıkarmak:

```bash
sudo borg extract /var/backups/borg-repo::<snapshot_adi> root/.borgmatic/mysql_databases/localhost/mysql_demo
```

MySQL içinde geri yüklemek:

```sql
USE mysql_demo;
SOURCE $HOME/root/.borgmatic/mysql_databases/localhost/mysql_demo;
```

Kontrol:

```sql
SELECT * FROM <table_name>;
```

Dosya Sistemi Üzerinde Yaptıklarım
	•Bir klasör oluşturdum ve içine test dosyaları koydum
	•Snapshot aldım
	•Dosyaları tamamen sildim
	•Borg’dan tek tek ve toplu şekilde geri yükledim

Tüm klasörü geri yüklemek:

```bash
sudo borg extract /var/backups/borg-repo::<snapshot_adi> $HOME/demo-folder
```

Kontrol:

```bash
cat ~/demo-folder/file1.txt
```