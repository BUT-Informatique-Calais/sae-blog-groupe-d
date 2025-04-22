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

# Installation de Yarn
RUN npm install -g yarn \
    && yarn --version || (echo "Yarn installation failed" && exit 1) # Vérification de l'installation de Yarn

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

# Copie des fichiers de configuration front-end
COPY package.json /var/www/html/
COPY yarn.lock /var/www/html/

# Installation des dépendances front-end
RUN yarn install \
    && yarn add @symfony/webpack-encore --dev # Ajout explicite de Webpack Encore

# Ensure the src directory exists with a placeholder file
RUN mkdir -p src \
    && echo "console.log('Placeholder file');" > src/index.js

# Compilation des fichiers statiques pour la production
RUN yarn encore production --mode=production

# Correction du chemin de l'autoloader dans index.php
RUN if [ -f "public/index.php" ]; then \
    sed -i "s|require_once.*autoload_runtime\.php|require_once dirname(__DIR__).'/vendor/autoload.php'|" public/index.php; \
    fi

# Vérification de l'installation de Composer
RUN composer install --no-interaction --optimize-autoloader || (echo "Composer install failed" && exit 1)

# Vérification de l'installation des dépendances Node.js
RUN if [ -f "package.json" ]; then \
    npm install && npm run build || (echo "Node.js build failed" && exit 1); \
    fi

# Vérification de la création des dossiers et permissions
RUN mkdir -p var/cache var/log \
    && touch var/data.db \
    && chown www-data:www-data var/data.db \
    && chmod 664 var/data.db \
    && chown -R www-data:www-data var \
    && chmod -R 777 var

# Vérification de la création du fichier SQLite
RUN touch var/data.db \
    && chown www-data:www-data var/data.db \
    && chmod 664 var/data.db

