#!/bin/bash
#
# pre-build.sh для DIR-620 D1 (RT3352)
# Flash: MX25L12872F (16 МБ) + RAM: AS4C32M16SB-6TIN (64 МБ)
#

echo "=== Патчи для 16 МБ Flash + 64 МБ RAM (DIR-620 D1) ==="

# === 1. RAM 64 МБ ===
echo "[1/3] Патчим RAM 64MB..."

find ./trunk -name "Board.dat" -exec sed -i 's/mem=32M/mem=64M/g' {} \;

KCFG="./trunk/configs/boards/DLINK/DIR-620D1/kernel-3.4.x.config"
if [ -f "$KCFG" ]; then
    sed -i 's/CONFIG_RT2880_DRAM_32M=y/CONFIG_RT2880_DRAM_64M=y/' "$KCFG"
    sed -i 's/CONFIG_RALINK_RAM_SIZE=32/CONFIG_RALINK_RAM_SIZE=64/' "$KCFG"
fi

# === 2. Flash 16 МБ + лимит размера прошивки (самое важное) ===
echo "[2/3] Патчим 16 МБ Flash и снимаем лимит размера..."

# mtdparts
find . -name "Board.dat" -exec sed -i 's/mtdparts=spi0.0:.*$/mtdparts=spi0.0:256k(bootloader)ro,64k(env),64k(factory),-(firmware)/g' {} \;

# Патч реального файла с лимитами (pt_ralink_8m_bigstor.config)
echo "Патчим pt_ralink_8m_bigstor.config..."
find . -name "pt_ralink_8m_bigstor.config" -exec sed -i 's/max_size=[0-9]*/max_size=16252928/g' {} \;
find . -name "pt_ralink_8m_bigstor.config" -exec sed -i 's/firmware_size=[0-9]*/firmware_size=15728640/g' {} \;
find . -name "pt_ralink_8m_bigstor.config" -exec sed -i 's/max_size=0x[0-9a-fA-F]*/max_size=0x00F80000/g' {} \;
find . -name "pt_ralink_8m_bigstor.config" -exec sed -i 's/0x770000/0xF00000/g' {} \;
find . -name "pt_ralink_8m_bigstor.config" -exec sed -i 's/7798784/16252928/g' {} \;

echo "Лимит размера увеличен до ~15.5 МБ"

# === 3. Финал ===
echo "[3/3] Готово."
echo ""
echo "После первой загрузки выполни:"
echo "  nvram set sdram_init=0x0013"
echo "  nvram commit"
echo "  reboot"
