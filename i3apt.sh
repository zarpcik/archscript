#!/bin/bash

# i3 kurulumunu kontrol et ve kur
if ! command -v i3 &> /dev/null; then
  echo "i3 kurulu değil. Kurulum yapılıyor..."
  sudo apt update
  sudo apt install -y i3
else
  echo "i3 zaten kurulu."
fi

# Sistemdeki mevcut kullanıcı adını al
CURRENT_USER=$(whoami)

# GitHub dosyasının URL'si (kullanıcı adını dinamik olarak ekle)
GITHUB_URL="https://github.com/$CURRENT_USER/repo_adi/raw/main/dosya_adi"

# Dosyanın yükleneceği klasör
TARGET_FOLDER="$HOME/.config/i3"

# Klasörün var olup olmadığını kontrol et
if [ ! -d "$TARGET_FOLDER" ]; then
  echo "Belirtilen klasör bulunamadı. Klasör oluşturuluyor: $TARGET_FOLDER"
  mkdir -p "$TARGET_FOLDER"
fi

# Dosya adını URL'den çıkar
FILE_NAME=$(basename "$GITHUB_URL")

# Dosyayı indir (curl kullanarak)
curl -o "$TARGET_FOLDER/$FILE_NAME" "$GITHUB_URL"

# İndirilen dosyanın tam yolu
LOCAL_FILE_PATH="$TARGET_FOLDER/$FILE_NAME"

# Dosyanın başarıyla indirilip indirilmediğini kontrol et
if [ -f "$LOCAL_FILE_PATH" ]; then
    echo "Dosya başarıyla indirildi: $LOCAL_FILE_PATH"
else
    echo "Dosya indirilemedi."
fi

# i3'ü varsayılan pencere yöneticisi olarak ayarla
if command -v update-alternatives &> /dev/null; then
  echo "i3'ü varsayılan pencere yöneticisi olarak ayarlanıyor (update-alternatives ile)..."
  sudo update-alternatives --set x-session-manager /usr/bin/i3
elif [ -f /etc/lightdm/lightdm.conf ]; then
  echo "i3'ü varsayılan pencere yöneticisi olarak ayarlanıyor (LightDM ile)..."
  sudo sed -i 's/^user-session=.*/user-session=i3/' /etc/lightdm/lightdm.conf
elif [ -f /etc/gdm3/custom.conf ]; then
  echo "i3'ü varsayılan pencere yöneticisi olarak ayarlanıyor (GDM ile)..."
  sudo sed -i 's/^WaylandEnable=.*/WaylandEnable=false/' /etc/gdm3/custom.conf
  sudo sed -i 's/^#WaylandEnable=.*/WaylandEnable=false/' /etc/gdm3/custom.conf
  sudo sed -i 's/^#UserSession=.*/UserSession=i3/' /etc/gdm3/custom.conf
else
  echo "Hata: Varsayılan pencere yöneticisi ayarlanamadı. Lütfen manuel olarak yapılandırın."
fi

echo "i3 başarıyla kuruldu ve varsayılan pencere yöneticisi olarak ayarlandı."