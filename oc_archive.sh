#!/bin/bash
set -x

# Крок 1: Отримуємо назву бази даних та інші дані з конфігураційного файлу OpenCart
DB_NAME=$(grep "DB_DATABASE" config.php | cut -d "'" -f 4)
DB_USER=$(grep "DB_USERNAME" config.php | cut -d "'" -f 4)
DB_PASSWORD=$(grep "DB_PASSWORD" config.php | cut -d "'" -f 4)
OWNER=$(ls -l config.php | awk '{print $3}')
STORAGE_PATH=$(grep "DIR_STORAGE" config.php | cut -d "'" -f 4)

# Перевірка чи отримана назва бази даних та шлях до storage коректні
if [ -z "$DB_NAME" ] || [ -z "$STORAGE_PATH" ]; then
	    echo "Помилка: Не вдалося отримати назву бази даних або шлях до директорії Storage з конфігураційного файлу OpenCart."
	        exit 1
	fi

	# Крок 2: Отримуємо розмір бази даних
	DB_SIZE=$(du -s /var/lib/mysql/$DB_NAME | cut -f1)

	# Розмір файлів сайту
	SITE_SIZE=$(du -s . | cut -f1)

	# Розмір директорії Storage
	STORAGE_SIZE=$(du -s $STORAGE_PATH | cut -f1)

	# Поточна дата у форматі YYYYMMDD
	CURRENT_DATE=$(date +"%Y%m%d")

	# Крок 3: Отримуємо дисковий простір
	DISK_SPACE=$(df -k . | awk 'NR==2{print $4}')

	# Виводимо результати
	echo "Назва бази даних: $DB_NAME"
	echo "Розмір бази даних: $DB_SIZE K"
	echo "Розмір сайту: $SITE_SIZE K"
	echo "Розмір директорії Storage: $STORAGE_SIZE K"
	echo "Доступний дисковий простір: $DISK_SPACE K"

	# Крок 4: Перевірка умови та виконання команд
	TOTAL_SIZE=$((DB_SIZE + SITE_SIZE + STORAGE_SIZE))

	if [ $DISK_SPACE -gt $TOTAL_SIZE ]; then
		    # Створюємо дамп бази даних з додаванням поточної дати до назви
		        mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > "${DB_NAME}_${CURRENT_DATE}.sql"

			    # Перевіряємо, чи був створений дамп
			        if [ -f "${DB_NAME}_${CURRENT_DATE}.sql" ]; then
					        # Архівуємо SQL файл, файли сайту та директорію Storage
						        chown $OWNER: ${DB_NAME}_${CURRENT_DATE}.sql
							        tar --exclude="wp_archive.sh"  -cvzf "backup_${CURRENT_DATE}.tar.gz" "${DB_NAME}_${CURRENT_DATE}.sql" ./* $STORAGE_PATH
								        # Змінюємо права на архів на власника
									        chown $OWNER: "backup_${CURRENT_DATE}.tar.gz"
										        # Видаляємо оригінальний SQL файл, щоб залишити тільки архів
											        rm "${DB_NAME}_${CURRENT_DATE}.sql"
												        echo "Резервна копія бази даних, сайту та директорії Storage успішно створена (у файлі backup_${CURRENT_DATE}.tar.gz)."
													    else
														            echo "Сталася помилка при створенні дампу бази даних."
															        fi
															else
																    echo "Недостатньо місця на диску для створення резервної копії."
															    fi

