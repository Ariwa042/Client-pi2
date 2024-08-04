FROM php:8.1-apache

# Install required PHP extensions and other dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libcurl4-openssl-dev

RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd

RUN docker-php-ext-install curl

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable mod_rewrite for Apache
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set the working directory
WORKDIR /var/www/html

# Copy the application files
COPY . /var/www/html

# Install PHP dependencies with Composer
RUN composer install

# Set permissions for the web server
RUN chown -R www-data:www-data /var/www/html/submissions && chmod -R 777 /var/www/html/submissions

# Start the Apache server
CMD ["apache2-foreground"]