FROM tutum/apache-php:latest
MAINTAINER Borja Burgos <borja@tutum.co>, Feng Honglin <hfeng@tutum.co>

# Install packages
RUN apt-get update && \
  apt-get -yq install mysql-client git wget unzip && \
  rm -rf /var/lib/apt/lists/*

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

# Amazon SES DKIM Mailer (https://wordpress.org/plugins/amazon-ses-and-dkim-mailer/)
RUN wget https://downloads.wordpress.org/plugin/amazon-ses-and-dkim-mailer.1.7.zip && unzip amazon-ses-and-dkim-mailer.1.7.zip

# MainWP (https://wordpress.org/plugins/MainWP/)
RUN wget https://downloads.wordpress.org/plugin/mainwp.2.0.6.zip && unzip mainwp.2.0.6.zip

# Expose environment variables
ENV DB_HOST **LinkMe**
ENV DB_PORT **LinkMe**
ENV DB_NAME wordpress
ENV DB_USER admin
ENV DB_PASS **ChangeMe**

EXPOSE 80
VOLUME ["/app/wp-content"]
CMD ["/run-wordpress.sh"]
