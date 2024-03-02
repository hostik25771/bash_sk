#!/bin/bash

echo "~~~~~~~Введіть домен~~~~~~~"
read domain
echo "~~~~~~~Введіть версію Node~~~~~~~"
read nodeV
echo "~~~~~~~Введіть назву користувача~~~~~~~"
read user
echo "~~~~~~~Введіть порт для додатку~~~~~~~"
read port
echo "~~~~~~~Введіть шлях до розгорнутих файлів додатку~~~~~~~"
read pathApp
echo "~~~~~~~Введіть IP для додатку~~~~~~~"
read ipMain
echo "~~~~~~~Введіть назву додатку~~~~~~~"
read nameApp

if [[ -z $domain ]]; then
        echo "Введіть домен!!!!!!"
elif [[ -z $nodeV ]]; then
        echo "Введіть версію Node!!!!!"

elif [[ -z $user ]]; then
        echo "Введіть назву користувача!!!!!!!"

elif [[ -z $port ]]; then
        echo "Введіть порт для додатку!!!!!!!!"

elif [[ -z $pathApp ]]; then
        echo "Введіть шлях до розгорнутих файлів додатку!!!!!!!"

elif [[ -z $ipMain ]]; then
                echo "Введіть IP для додатку!!!!!!!!"

        elif [[ -z $nameApp ]]; then
                                echo "Введіть назву додатку!!!!!!!!"

else
if [[ -n $pathApp ]]; then
         #Перевірка на наявність всіх змін закінчена/початок скрипта
        
         # 1. Встановлюємо та запускаємо Nginx

         dnf install nginx -y && service nginx start

         # 2. Створюємо користувача та кореневу директорію сайту

         adduser $user && mkdir /home/$user/public_html

         # 3. Переміщуємо файли проекту до кореневої директорії сайту

        cp -a $pathApp/* /home/$user/public_html && chown -R $user: /home/$user/public_html

        # 4. Створюємо логи та конф для вебсервера Nginx
        touch /home/$user/requests.log
        touch /home/$user/error.log
        touch /etc/nginx/conf.d/$domain.conf

        # 5. Наповнюємо конф для сайту + налаштовуємо Proxy
        echo "server {
 listen 80;
 server_name $domain;
 location / {
   proxy_pass http://$ipMain:$port/;
   proxy_set_header Host \$host;
   proxy_set_header X-Real-IP \$remote_addr;
   proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
   proxy_set_header X-Forwarded-Proto \$scheme;
   proxy_pass_request_headers on;
    }
  error_log /home/$user/error.log;
  access_log /home/$user/requests.log combined;
  }" > /etc/nginx/conf.d/$domain.conf

 # 6. Встановлення NodeJS
        dnf module list nodejs
        dnf module install nodejs:$nodeV -y --nogpgcheck

        # 7. Встановлення npm + pm2
        dnf install npm -y && npm install pm2@latest -g

        # 8. Запус додатку
        service nginx reload && cd /home/$user/public_html && pm2 start npm --name "$nameApp" -- start
        
#END

 fi
fi
