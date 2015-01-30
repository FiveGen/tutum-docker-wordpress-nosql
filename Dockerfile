FROM tutum/apache-php:latest
MAINTAINER Borja Burgos <borja@tutum.co>, Feng Honglin <hfeng@tutum.co>

# Install packages
RUN apt-get update && \
  apt-get -yq install mysql-client git wget unzip && \
  rm -rf /var/lib/apt/lists/*

# Install WP-CLI (http://wp-cli.org/)
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

# Add permalink feature
RUN a2enmod rewrite
ADD wordpress.conf /etc/apache2/sites-enabled/000-default.conf

# Download latest version of Wordpress into /app
RUN rm -fr /app
ADD WordPress/ /app
ADD wp-config.php /app/wp-config.php

# Add script to create 'wordpress' DB
ADD run-wordpress.sh /run-wordpress.sh
RUN chmod 755 /*.sh

# Modify permissions to allow plugin upload
RUN chmod -R 777 /app/wp-content

# Clone and link OneMozilla theme
RUN git clone https://github.com/Mozilla-cIT/One-Mozilla-blog /app/wp-content/One-Mozilla-blog
RUN ln -sf /app/wp-content/One-Mozilla-blog/themes/OneMozilla /app/wp-content/themes/OneMozilla

# Install all the plugins
WORKDIR /app/wp-content/plugins

### Begin plugin installation ###

# Google Authenticator (https://wordpress.org/plugins/google-authenticator/)
RUN wget https://downloads.wordpress.org/plugin/google-authenticator.0.47.zip && unzip google-authenticator.0.47.zip

# Jetpack (https://wordpress.org/plugins/jetpack/)
RUN wget https://downloads.wordpress.org/plugin/jetpack.3.3.zip && unzip jetpack.3.3.zip

# WordPress Importer (https://downloads.wordpress.org/plugin/wordpress-importer.0.6.1.zip)
RUN wget https://downloads.wordpress.org/plugin/wordpress-importer.0.6.1.zip && unzip wordpress-importer.0.6.1.zip

# Amazon Web Services (https://wordpress.org/plugins/amazon-web-services/)
RUN wget https://downloads.wordpress.org/plugin/amazon-web-services.0.2.2.zip && unzip amazon-web-services.0.2.2.zip

# Amazon S3 and Cloudfront (https://wordpress.org/plugins/amazon-s3-and-cloudfront/)
RUN wget https://downloads.wordpress.org/plugin/amazon-s3-and-cloudfront.0.8.1.zip && unzip amazon-s3-and-cloudfront.0.8.1.zip

# Amazon SES DKIM Mailer (https://wordpress.org/plugins/amazon-ses-and-dkim-mailer/)
RUN wget https://downloads.wordpress.org/plugin/amazon-ses-and-dkim-mailer.1.7.zip && unzip amazon-ses-and-dkim-mailer.1.7.zip

# Wordfence Security (https://wordpress.org/plugins/wordfence/)
RUN wget https://downloads.wordpress.org/plugin/wordfence.5.3.5.zip && unzip wordfence.5.3.5.zip

# User Role Editor (https://wordpress.org/plugins/user-role-editor/)
RUN wget https://downloads.wordpress.org/plugin/user-role-editor.4.18.1.zip && unzip user-role-editor.4.18.1.zip

# MainWP Child (https://wordpress.org/plugins/mainwp-child/)
RUN wget https://downloads.wordpress.org/plugin/mainwp-child.2.0.6.zip && unzip mainwp-child.2.0.6.zip

### End plugin installation ###

# Expose environment variables
ENV DB_HOST **LinkMe**
ENV DB_PORT **LinkMe**
ENV DB_NAME wordpress
ENV DB_USER admin
ENV DB_PASS **ChangeMe**
ENV AWS_ACCESS_KEY_ID **ChangeMe**
ENV AWS_SECRET_ACCESS_KEY **ChangeMe**
ENV WP_TITLE **ChangeMe**
ENV WP_ADMIN_USER **ChangeMe**
ENV WP_ADMIN_PASSWORD **ChangeMe**
ENV WP_ADMIN_EMAIL **ChangeMe**

EXPOSE 80
VOLUME ["/app/wp-content"]
CMD ["/run-wordpress.sh"]

# Install WordPress and activate all plugins
WORKDIR /app
CMD ["sudo", "-u", "www-data", "-s", "wp", "--allow-root", "core", "install", "--title=$WP_TITLE", "--admin_user=$WP_ADMIN_USER", "--admin_password=$WP_ADMIN_PASSWORD", "--admin_email=$WP_ADMIN_EMAIL", "&&", "sudo", "-u", "www-data", "-s", "wp", "--allow-root", "plugin", "activate", "--all"]
