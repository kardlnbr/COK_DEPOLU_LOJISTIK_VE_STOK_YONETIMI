CREATE DATABASE StokYonetim;
GO

USE StokYonetim;
GO

create table depolar(
depoID int identity(1,1) primary key,
depoAdi varchar(100) not null unique,
depoTipi varchar(10) not null check (depoTipi in ('Merkez','Sube')),
sehir varchar(50) not null,
adres varchar(250) null,
telefon varchar(20) null,
sorumlu varchar(100) null,
aktif bit not null default 1
);

create table kategoriler(
kategoriID int identity(1,1) primary key,
kategoriAdi varchar(100) not null,
ustKategoriID int null foreign key references kategoriler(kategoriID),   -- bos ise ana kategori
aciklama varchar(250) null
);

create table tedarikciler(
tedarikciID int identity(1,1) primary key,
firmaAdi varchar(150) not null,
vergiNo varchar(11) not null unique,
yetkili varchar(100) null,
telefon varchar(20) null,
email varchar(100) null,
adres varchar(250) null
);

create table musteriler(
musteriID int identity(1,1) primary key,
musteriTipi varchar(10) not null check (musteriTipi in ('Bireysel','Bayi')),
adSoyadUnvan varchar(150) not null,
telefon varchar(20) null,
email varchar(100) null,
adres varchar(250) null
);

create table urunler(
urunID int identity(1,1) primary key,
kategoriID int not null foreign key references kategoriler(kategoriID),
urunAdi varchar(150) not null,
barkod varchar(30) not null unique,
birim varchar(10) not null default 'Adet',
alisFiyati decimal(10,2) not null,
satisFiyati decimal(10,2) not null,
kdvOrani decimal(5,2) not null default 20
);

create table urunTedarikci(
urunID int not null foreign key references urunler(urunID),
tedarikciID int not null foreign key references tedarikciler(tedarikciID),
primary key (urunID, tedarikciID)
);

create table stoklar(
stokID int identity(1,1) primary key,
depoID int not null foreign key references depolar(depoID),
urunID int not null foreign key references urunler(urunID),
miktar int not null default 0 check (miktar >= 0),
kritikSeviye int not null default 0,
unique (depoID, urunID)   -- ayni depoda ayni urun tek satir olur
);

create table transferEmirleri(
transferID int identity(1,1) primary key,
kaynakDepoID int not null foreign key references depolar(depoID),
hedefDepoID int not null foreign key references depolar(depoID),
durum varchar(20) not null default 'Beklemede' check (durum in ('Beklemede','Onaylandi','Yolda','Tamamlandi','Iptal')),
talepTarihi datetime not null default getdate(),
aciklama varchar(250) null,
check (kaynakDepoID <> hedefDepoID) -- kaynak ve hedef depo ayni olamaz
);

create table transferDetay(
transferDetayID int identity(1,1) primary key,
transferID int not null foreign key references transferEmirleri(transferID),
urunID int not null foreign key references urunler(urunID),
miktar int not null check (miktar > 0)
);

create table siparisler(
siparisID int identity(1,1) primary key,
musteriID int not null foreign key references musteriler(musteriID),
siparisTarihi datetime not null default getdate(),
durum varchar(20) not null default 'Beklemede' check (durum in ('Beklemede','Hazirlaniyor','Sevk Edildi','Teslim Edildi','Iptal'))
);

create table siparisDetay(
siparisDetayID int identity(1,1) primary key,
siparisID int not null foreign key references siparisler(siparisID),
urunID int not null foreign key references urunler(urunID),
depoID int not null foreign key references depolar(depoID),
miktar int not null check (miktar > 0),
birimFiyat decimal(10,2) not null,
kdvOrani decimal(5,2) not null,
iskontoOrani decimal(5,2) not null default 0
);

create table stokHareketleri(
hareketID int identity(1,1) primary key,
depoID int not null foreign key references depolar(depoID),
urunID int not null foreign key references urunler(urunID),
hareketTipi varchar(20) not null check (hareketTipi in ('Giris','Cikis','TransferGiris','TransferCikis')),
miktar int not null check (miktar > 0),
hareketTarihi datetime not null default getdate(),
tedarikciID int null foreign key references tedarikciler(tedarikciID),
siparisID int null foreign key references siparisler(siparisID),
transferID int null foreign key references transferEmirleri(transferID),
aciklama varchar(250) null
);
go
