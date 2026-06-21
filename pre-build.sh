#!/bin/bash
#
# pre-build.sh для DIR-620 D1 (RT3352)
# Поддержка: MX25L12872F (16 МБ Flash) + AS4C32M16SB-6TIN (64 МБ RAM)
#

echo "=== Патчи для 16 МБ Flash + 64 МБ RAM (DIR-620 D1) ==="

# 1. RAM 64 МБ
echo "[1/3] Патчим RAM 64MB..."
find ./trunk -name "Board.dat" -exec sed -i 's/mem=32M/mem=64M/g' {} \;

KCFG="./trunk/configs/boards/DLINK/DIR-620D1/kernel-3.4.x.config"
if [ -f "$KCFG" ]; then
    sed -i 's/CONFIG_RT2880_DRAM_32M=y/CONFIG_RT2880_DRAM_64M=y/' "$KCFG"
    sed -i 's/CONFIG_RALINK_RAM_SIZE=32/CONFIG_RALINK_RAM_SIZE=64/' "$KCFG"
fi

# 2. Flash 16 МБ + снятие лимита размера прошивки
echo "[2/3] Патчим Flash 16MB и убираем лимит max_fw_size..."

# mtdparts
MTDPARTS="mtdparts=spi0.0:256k(bootloader)ro,64k(env),64k(factory),-(firmware)"
find ./trunk -name "Board.dat" -exec sed -i "s|mtdparts=spi0.0:.*$|${MTDPARTS}|g" {} \;

# Снимаем лимит размера (главное!)
find ./trunk -name "partitions.config" -o -name "*8m*.config" 2>/dev/null | while read cfg; do
    [ -f "$cfg" ] || continue
    sed -i 's/max_size=[0-9]*/max_size=15728640/g' "$cfg" 2>/dev/null || true
    sed -i 's/7798784/15728640/g' "$cfg" 2>/dev/null || true
    sed -i 's/0x770000/0xF00000/g' "$cfg" 2>/dev/null || true
done

# 3. Финал
echo "[3/3] Готово. Можно собирать."
echo ""
echo "После первой загрузки выполни:"
echo "  nvram set sdram_init=0x0013"
echo "  nvram commit"
echo "  reboot"
