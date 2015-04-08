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
WORKDIR /app/wp-content/themes
RUN wget http://csa-wordpress.s3.amazonaws.com/plugins/mozilla.zip && unzip mozilla.zip

# Install all the plugins
WORKDIR /app/wp-content/plugins

# Amazon SES DKIM Mailer (https://wordpress.org/plugins/amazon-ses-and-dkim-mailer/)
RUN wget https://downloads.wordpress.org/plugin/amazon-ses-and-dkim-mailer.1.7.zip && unzip amazon-ses-and-dkim-mailer.1.7.zip

# Amazon SES DKIM Mailer (https://wordpress.org/plugins/amazon-ses-and-dkim-mailer/)
RUN wget https://downloads.wordpress.org/plugin/easing-slider.2.2.1.1.zip && unzip easing-slider.2.2.1.1.zip

# MainWP (https://wordpress.org/plugins/MainWP/)
RUN wget https://downloads.wordpress.org/plugin/mainwp.2.0.10.zip && unzip mainwp.2.0.10.zip

# MainWP Extensions (https://extensions.mainwp.com)
RUN wget http://csa-wordpress.s3.amazonaws.com/plugins/advanced-uptime-monitor-extension.zip && unzip advanced-uptime-monitor-extension.zip
RUN wget http://csa-wordpress.s3.amazonaws.com/plugins/mainwp-clean-and-lock-extension.zip && unzip mainwp-clean-and-lock-extension.zip
RUN wget http://csa-wordpress.s3.amazonaws.com/plugins/mainwp-sucuri-extension.zip && unzip mainwp-sucuri-extension.zip

# Expose environment variables
ENV DB_HOST **LinkMe**
ENV DB_PORT **LinkMe**
ENV DB_NAME wordpress
ENV DB_USER admin
ENV DB_PASS **ChangeMe**

EXPOSE 80
VOLUME ["/app/wp-content"]
CMD ["/run-wordpress.sh"]
