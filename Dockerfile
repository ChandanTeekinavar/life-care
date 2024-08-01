FROM php:8.2.0-apache

WORKDIR /var/www/html/

# Install Linux Libraries
RUN apt-get update -y && apt-get install -y \
   libicu-dev \
   unzip zip \
   zlib1g-dev \
   libpng-dev \
   libjpeg-dev \
   libfreetype6-dev \
   libjpeg62-turbo-dev \
   vim \
   curl \
   git \ 
   libpng-dev

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install PHP Extensions
RUN docker-php-ext-install gettext intl pdo_mysql gd

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY . .

COPY .env.example .env

# Run migration and seed, generate application key, and start the server
RUN composer install

RUN composer update

RUN php artisan key:generate

RUN php artisan config:clear

RUN php artisan cache:clear

RUN composer dump-autoload

RUN php artisan clear-compiled  

RUN php artisan session:table

RUN php artisan storage:link

EXPOSE 8000

#CMD [php artisan migrate:refresh --seed  && php artisan serve --host=0.0.0.0 --port=8000]

# CMD ["sh", "-c", "composer update && php artisan key:generate && php artisan migrate && php artisan serve --host=0.0.0.0 --port=8000"]

CMD ["sh", "-c", "php artisan migrate:fresh --seed && php artisan serve --host=0.0.0.0 --port=8000"]