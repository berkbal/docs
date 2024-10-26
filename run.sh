#!/bin/bash

# Sanal ortam oluşturma
python3 -m venv venv

# Gereksinimleri yükleme (sanal ortamı etkinleştirerek)
source venv/bin/activate && pip install -r requirements.txt

echo "Sanal ortam oluşturuldu ve gereksinimler yüklendi."
echo "Sanal ortamı aktif etmek için 'source venv/bin/activate' komutunu kullanın."
