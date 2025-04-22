FROM php:8.2-apache

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libicu-dev \
    libsqlite3-dev \
    nodejs \
    npm \
    && docker-php-ext-install \
    pdo \
    pdo_sqlite \
    zip \
    intl

# Activation du module rewrite d'Apache
RUN a2enmod rewrite

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configuration du DocumentRoot d'Apache
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Configuration du répertoire de travail
WORKDIR /var/www/html

# Copie des fichiers de l'application
COPY . .

# Correction du chemin de l'autoloader dans index.php
RUN if [ -f "public/index.php" ]; then \
    sed -i "s|require_once.*autoload_runtime\.php|require_once dirname(__DIR__).'/vendor/autoload.php'|" public/index.php; \
    fi

# Installation des dépendances PHP via Composer
RUN composer install --no-interaction --optimize-autoloader

# Installation des dépendances Node.js et build assets uniquement si package.json existe
RUN if [ -f "package.json" ]; then \
    npm install && npm run build; \
    fi

# Création explicite du dossier pour la base de données SQLite
RUN mkdir -p var/data
RUN touch var/data/blog.sqlite
RUN chmod 777 var/data/blog.sqlite
RUN chown -R www-data:www-data var vendor

# Exposition du port
EXPOSE 80