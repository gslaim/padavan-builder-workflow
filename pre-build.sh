#!/bin/bash
echo "=== ПАТЧ ДЛЯ 16 МБ FLASH (MX25L12872F) на DIR-620 D1 ==="

# Патч mtd-партиций
find . -name "Board.dat" -exec sed -i 's/mtdparts=spi0.0:.*$/mtdparts=spi0.0:256k(bootloader)ro,64k(env),64k(factory),-(firmware)/g' {} \;

# Патч настоящего файла с лимитами размера (8m_bigstor)
echo "Патчим pt_ralink_8m_bigstor.config..."

find . -name "pt_ralink_8m_bigstor.config" -exec sed -i 's/max_size=[0-9]*/max_size=16252928/g' {} \;
find . -name "pt_ralink_8m_bigstor.config" -exec sed -i 's/firmware_size=[0-9]*/firmware_size=15728640/g' {} \;

find . -name "pt_ralink_8m_bigstor.config" -exec sed -i 's/max_size=0x[0-9a-fA-F]*/max_size=0x00F80000/g' {} \;
find . -name "pt_ralink_8m_bigstor.config" -exec sed -i 's/0x770000/0xF00000/g' {} \;
find . -name "pt_ralink_8m_bigstor.config" -exec sed -i 's/7798784/16252928/g' {} \;

echo "Лимит размера увеличен до ~15.5 МБ"
echo "Патч mtdparts + размер flash завершён"
