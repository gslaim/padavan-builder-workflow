#!/bin/bash
#
# САМЫЙ ЖЁСТКИЙ pre-build.sh
# DIR-620 D1 + MX25L12872F (16MB) + AS4C32M16SB-6TIN (64MB)
#

echo "=== ЖЁСТКИЕ ПАТЧИ U-BOOT + KERNEL + RAM ==="

# 1. RAM 64 МБ (максимально агрессивно)
echo "[1] Патчим RAM 64MB..."

find ./trunk -name "Board.dat" -exec sed -i 's/mem=32M/mem=64M/g' {} \;

KCFG="./trunk/configs/boards/DLINK/DIR-620D1/kernel-3.4.x.config"
if [ -f "$KCFG" ]; then
    sed -i 's/CONFIG_RT2880_DRAM_32M=y/CONFIG_RT2880_DRAM_64M=y/' "$KCFG"
    sed -i 's/CONFIG_RALINK_RAM_SIZE=32/CONFIG_RALINK_RAM_SIZE=64/' "$KCFG"
fi

# 2. Flash 16 МБ + снятие лимитов
echo "[2] Flash 16MB + снятие лимитов..."

MTDPARTS="mtdparts=spi0.0:256k(bootloader)ro,64k(env),64k(factory),-(firmware)"
find ./trunk -name "Board.dat" -exec sed -i "s|mtdparts=spi0.0:.*$|${MTDPARTS}|g" {} \;

find ./trunk -name "partitions.config" -o -name "*8m*.config" 2>/dev/null | while read cfg; do
    [ -f "$cfg" ] || continue
    sed -i 's/max_size=[0-9]*/max_size=15728640/g' "$cfg" 2>/dev/null || true
    sed -i 's/7798784/15728640/g' "$cfg" 2>/dev/null || true
done

# 3. Патч u-boot (самое жёсткое)
echo "[3] Патчим u-boot для 64 МБ RAM..."

UBOOT_CFG="./trunk/bootloader/u-boot-1.1.4/include/configs/rt2880.h"  # или rt3352.h — подкорректируй путь, если другой
if [ -f "$UBOOT_CFG" ]; then
    sed -i 's/#define CONFIG_SYS_SDRAM_SIZE.*32M/#define CONFIG_SYS_SDRAM_SIZE 64M/g' "$UBOOT_CFG" 2>/dev/null || true
    sed -i 's/#define CONFIG_SYS_SDRAM_SIZE.*0x2000000/#define CONFIG_SYS_SDRAM_SIZE 0x4000000/g' "$UBOOT_CFG" 2>/dev/null || true
    echo "    u-boot пропатчен (если файл найден)"
else
    echo "    u-boot config не найден — проверь путь в скрипте"
fi

# 4. Форсируем sdram_init в прошивке
echo "[4] Форсируем sdram_init..."

mkdir -p ./trunk/user/scripts
cat > ./trunk/user/scripts/force_sdram.sh << 'EOF'
#!/bin/sh
# Жёсткая установка нескольких параметров
nvram set sdram_init=0x000B
nvram set sdram_config=0x0000
nvram set mem=64M
nvram commit
EOF
chmod +x ./trunk/user/scripts/force_sdram.sh

echo "Готово. Самый жёсткий вариант собран."
echo "После прошивки проверь dmesg | grep -i memory"
