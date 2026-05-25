#!/bin/bash
echo "=== ПАТЧ ДЛЯ 16 МБ FLASH (MX25L12872F) на DIR-620 D1 ==="

# 1. Патч mtd-партиций (чтобы ядро видело весь flash)
find ./trunk -name "Board.dat" -exec sed -i 's/mtdparts=spi0.0:.*$/mtdparts=spi0.0:256k(bootloader)ro,64k(env),64k(factory),-(firmware)/g' {} \;

# 2. Патч лимита размера прошивки (самое важное сейчас!)
# Меняем старый лимит ~7.4 МБ на ~15 МБ
sed -i 's/max_size=[0-9]*/max_size=0x00F80000/' ./trunk/configs/boards/DLINK/DIR-620D1/partitions.config 2>/dev/null || true
sed -i 's/firmware_size=[0-9]*/firmware_size=0x00F00000/' ./trunk/configs/boards/DLINK/DIR-620D1/partitions.config 2>/dev/null || true

# На всякий случай патчим все возможные места
sed -i 's/7798784/16252928/g' ./trunk/configs/boards/DLINK/DIR-620D1/partitions.config 2>/dev/null || true
sed -i 's/0x770000/0xF00000/g' ./trunk/configs/boards/DLINK/DIR-620D1/partitions.config 2>/dev/null || true

echo "Патч mtdparts + увеличение лимита размера до ~15 МБ выполнен"
