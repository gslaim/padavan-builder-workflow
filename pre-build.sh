#!/bin/bash
echo "=== ПАТЧ ТОЛЬКО ДЛЯ 16 МБ FLASH (MX25L12872F) на DIR-620 D1 ==="

# Патч mtd-партиций под 16 МБ flash
find ./trunk -name "Board.dat" -exec sed -i 's/mtdparts=spi0.0:.*$/mtdparts=spi0.0:256k(bootloader)ro,64k(env),64k(factory),-(firmware)/g' {} \;

echo "Патч mtdparts для 16 МБ Flash успешно применён"
echo "RAM патчить не будем (как просил)"
