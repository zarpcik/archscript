#!/bin/bash

# i3 kurulumunu kontrol et ve kur
if ! command -v i3 &> /dev/null; then
  echo "i3 kurulu değil. Kurulum yapılıyor..."
  sudo pacman -Sy --noconfirm i3
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
if command -v lightdm &> /dev/null; then
  echo "i3'ü varsayılan pencere yöneticisi olarak ayarlanıyor (LightDM ile)..."
  sudo sed -i 's/^user-session=.*/user-session=i3/' /etc/lightdm/lightdm.conf
  sudo systemctl enable lightdm --now
elif command -v sddm &> /dev/null; then
  echo "i3'ü varsayılan pencere yöneticisi olarak ayarlanıyor (SDDM ile)..."
  sudo mkdir -p /etc/sddm.conf.d/
  echo -e "[Autologin]\nUser=$CURRENT_USER\nSession=i3" | sudo tee /etc/sddm.conf.d/autologin.conf > /dev/null
  sudo systemctl enable sddm --now
else
  echo "Hata: LightDM veya SDDM bulunamadı. Lütfen manuel olarak yapılandırın."
fi

echo "i3 başarıyla kuruldu ve varsayılan pencere yöneticisi olarak ayarlandı."
