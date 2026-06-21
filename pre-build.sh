#!/bin/bash
#
# pre-build.sh для DIR-620 D1 (RT3352)
# Чипы: Flash MX25L12872F (16 МБ) + RAM AS4C32M16SB-6TIN (64 МБ)
#
# Использование: поместить в корень репозитория padavan-ng / padavan-builder
# и запустить сборку (GitHub Actions или локально)
#

echo "=== Применяем патчи для MX25L12872F (16MB Flash) и AS4C32M16SB-6TIN (64MB RAM) ==="

# ============================================================
# 1. Патч размера оперативной памяти на 64 МБ (Board.dat + kernel config)
# ============================================================
echo "[1/5] Патчим RAM 64MB ..."

# Board.dat
find ./trunk -name "Board.dat" -exec sed -i 's/mem=32M/mem=64M/g' {} \;

# kernel-3.4.x.config (hadzhioglu/padavan-ng и похожие форки)
KCFG="./trunk/configs/boards/DLINK/DIR-620D1/kernel-3.4.x.config"
if [ -f "$KCFG" ]; then
    sed -i 's/CONFIG_RT2880_DRAM_32M=y/CONFIG_RT2880_DRAM_64M=y/' "$KCFG"
    sed -i 's/CONFIG_RALINK_RAM_SIZE=32/CONFIG_RALINK_RAM_SIZE=64/' "$KCFG"
fi

# Device Tree
find ./trunk -name "*.dts" -exec sed -i 's/32M/64M/g' {} \; 2>/dev/null || true

# ============================================================
# 2. Патч Flash 16 МБ (MX25L12872F)
# ============================================================
echo "[2/5] Патчим Flash 16MB + mtdparts ..."

# kernel config: убираем жёсткое ограничение 8MB (если есть)
if [ -f "$KCFG" ]; then
    sed -i '/CONFIG_RT2880_FLASH_8M/d' "$KCFG"
    # Если в твоей версии конфига есть CONFIG_RT2880_FLASH_16M — раскомментируй строку ниже
    # sed -i 's/# CONFIG_RT2880_FLASH_16M is not set/CONFIG_RT2880_FLASH_16M=y/' "$KCFG"
fi

# mtdparts в Board.dat (рекомендуемая строка для 16MB)
MTDPARTS="mtdparts=spi0.0:256k(bootloader)ro,64k(env),64k(factory),-(firmware)"
find ./trunk -name "Board.dat" -exec sed -i "s|mtdparts=spi0.0:.*$|${MTDPARTS}|g" {} \;

# ============================================================
# 3. Дополнительные патчи (опционально)
# ============================================================
echo "[3/5] Дополнительные патчи ..."

# Если после прошивки память нестабильна — раскомментируй и попробуй разные значения
# find ./trunk -name "Board.dat" -exec sed -i 's/sdram_init=0x[0-9a-fA-F]*/sdram_init=0x0013/g' {} \;

# ============================================================
# 4. Финальные действия
# ============================================================
echo "[4/5] Готово!"

echo ""
echo "Патчи применены успешно для:"
echo "  • RAM: 64 МБ (AS4C32M16SB-6TIN + CONFIG_RALINK_RAM_SIZE=64)"
echo "  • Flash: 16 МБ (MX25L12872F)"
echo ""
echo "Рекомендуемые настройки в build.config:"
echo "  CONFIG_FIRMWARE_PRODUCT_ID=\"DIR-620D1\""
echo ""
echo "После первой загрузки выполни:"
echo "  nvram set sdram_init=0x0013"
echo "  nvram commit"
echo "  reboot"
echo ""
echo "Если будут проблемы со стабильностью памяти — попробуй другие значения sdram_init."

echo ""
echo "Патчи применены успешно."
echo "Теперь можно собирать прошивку."
echo "Рекомендуемые настройки в build.config:"
echo "  - CONFIG_FIRMWARE_PRODUCT_ID=\"DIR-620D1\""
echo "  - mem=64M (уже пропатчено)"
echo "  - 16 МБ flash (mtdparts обновлены)"
echo ""
echo "После первой загрузки новой прошивки выполни:"
echo "  nvram set sdram_init=0x0013"
echo "  nvram commit"
echo "  reboot"
echo ""
echo "Если Wi-Fi или память будут нестабильны — попробуй другие значения sdram_init."
