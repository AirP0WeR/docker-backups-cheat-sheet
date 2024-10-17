#!/bin/bash

# Папка с архивами
BACKUP_DIR="/path/to/backup"

# Проверяем, существует ли папка с архивами
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Папка $BACKUP_DIR не найдена."
    exit 1
fi

# Проходим по каждому архиву в папке
for archive in "$BACKUP_DIR"/*.tar.gz; do
    # Извлекаем имя тома из названия файла (удаляем путь и расширение)
    volume_name=$(basename "$archive" .tar.gz)

    # Проверяем, существует ли такой том уже
    if docker volume ls --format '{{.Name}}' | grep -q "^$volume_name$"; then
        echo "Том $volume_name уже существует, пропускаем."
        continue
    fi

    # Создаем новый том
    echo "Создаем том: $volume_name"
    docker volume create "$volume_name"

    # Восстанавливаем данные из архива в том
    echo "Восстанавливаем данные для тома: $volume_name"
    docker run --rm -v "$volume_name":/volume -v "$BACKUP_DIR":/backup alpine sh -c "cd /volume && tar -xzf /backup/$volume_name.tar.gz"

    echo "Том $volume_name успешно восстановлен."
done

echo "Восстановление завершено."