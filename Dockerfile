# Utilisation de l'image PHP avec Apache
FROM php:8.2-apache

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libicu-dev \
    libsqlite3-dev \
    sqlite3 \
    && docker-php-ext-install \
    pdo \
    pdo_sqlite \
    intl \
    zip

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Activation du module rewrite d'Apache
RUN a2enmod rewrite

# Configuration du DocumentRoot d'Apache
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Configuration du répertoire de travail
WORKDIR /var/www/html

# Copie de tous les fichiers avant d'exécuter composer install
COPY . .

# Installation des dépendances PHP sans exécuter les scripts post-installation
RUN composer install --no-scripts --optimize-autoloader

# Exécution des scripts post-installation manuellement
RUN composer run-script post-install-cmd

# Configuration des permissions
RUN chown -R www-data:www-data /var/www/html/var && chmod -R 775 /var/www/html/var

# Initialisation de la base de données et des migrations
RUN php bin/console doctrine:database:drop --force || true \
    && php bin/console doctrine:database:create \
    && php bin/console doctrine:migrations:migrate --no-interaction

# Commande par défaut
CMD ["apache2-foreground"]

