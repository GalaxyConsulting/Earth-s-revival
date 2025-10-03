#!/bin/bash

# Earth's Revival - Archive Extraction Helper Script
# Этот скрипт помогает распаковать архив сайта

set -e

echo "🌍 Earth's Revival - Archive Extraction Helper"
echo "=============================================="
echo ""

# Check if archive file is provided
if [ $# -eq 0 ]; then
    echo "❌ Ошибка: Не указан файл архива"
    echo ""
    echo "Использование:"
    echo "  ./extract-archive.sh <путь-к-архиву.zip>"
    echo ""
    echo "Пример:"
    echo "  ./extract-archive.sh ~/Downloads/mysite.zip"
    exit 1
fi

ARCHIVE_PATH="$1"
WEBSITE_DIR="website"

# Check if archive exists
if [ ! -f "$ARCHIVE_PATH" ]; then
    echo "❌ Ошибка: Файл '$ARCHIVE_PATH' не найден"
    exit 1
fi

# Detect archive type
ARCHIVE_EXT="${ARCHIVE_PATH##*.}"
echo "📦 Обнаружен архив типа: .$ARCHIVE_EXT"
echo ""

# Backup existing website directory if it exists and has content
if [ -d "$WEBSITE_DIR" ] && [ "$(ls -A $WEBSITE_DIR 2>/dev/null)" ]; then
    BACKUP_DIR="website-backup-$(date +%Y%m%d-%H%M%S)"
    echo "💾 Создание резервной копии существующей папки website..."
    mv "$WEBSITE_DIR" "$BACKUP_DIR"
    echo "✅ Резервная копия создана: $BACKUP_DIR"
    echo ""
fi

# Create website directory
mkdir -p "$WEBSITE_DIR"

# Extract archive based on type
echo "📂 Распаковка архива в папку $WEBSITE_DIR..."
case "$ARCHIVE_EXT" in
    zip)
        unzip -q "$ARCHIVE_PATH" -d "$WEBSITE_DIR"
        ;;
    tar)
        tar -xf "$ARCHIVE_PATH" -C "$WEBSITE_DIR"
        ;;
    gz|tgz)
        tar -xzf "$ARCHIVE_PATH" -C "$WEBSITE_DIR"
        ;;
    bz2|tbz)
        tar -xjf "$ARCHIVE_PATH" -C "$WEBSITE_DIR"
        ;;
    *)
        echo "❌ Ошибка: Неподдерживаемый тип архива .$ARCHIVE_EXT"
        echo "Поддерживаемые форматы: .zip, .tar, .tar.gz, .tgz, .tar.bz2, .tbz"
        exit 1
        ;;
esac

echo "✅ Архив распакован"
echo ""

# Check if files were extracted into a subdirectory
SUBDIR_COUNT=$(find "$WEBSITE_DIR" -maxdepth 1 -mindepth 1 -type d | wc -l)
FILE_COUNT=$(find "$WEBSITE_DIR" -maxdepth 1 -type f | wc -l)

if [ "$SUBDIR_COUNT" -eq 1 ] && [ "$FILE_COUNT" -eq 0 ]; then
    SUBDIR=$(find "$WEBSITE_DIR" -maxdepth 1 -mindepth 1 -type d)
    echo "📁 Обнаружена вложенная папка, перемещаю файлы..."
    mv "$SUBDIR"/* "$WEBSITE_DIR"/
    rmdir "$SUBDIR"
    echo "✅ Файлы перемещены в корень website/"
    echo ""
fi

# List contents
echo "📋 Содержимое папки website/:"
ls -lh "$WEBSITE_DIR" | head -n 20

# Check for index.html
if [ -f "$WEBSITE_DIR/index.html" ]; then
    echo ""
    echo "✅ Найден файл index.html"
else
    echo ""
    echo "⚠️  Предупреждение: Файл index.html не найден в корне website/"
    echo "   Убедитесь, что структура архива правильная"
fi

echo ""
echo "🎉 Готово! Следующие шаги:"
echo "   1. Проверьте содержимое папки website/"
echo "   2. Запустите локальный сервер для тестирования:"
echo "      cd website && python -m http.server 8000"
echo "   3. Зафиксируйте изменения:"
echo "      git add ."
echo "      git commit -m 'Добавлены файлы сайта'"
echo "      git push"
echo ""
