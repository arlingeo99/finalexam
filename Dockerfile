FROM ubuntu:20.04
 
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y apache2 php php-mysql
 
RUN rm -rf /var/www/html/index.html

COPY application-code/ /var/www/html/
 
EXPOSE 80
 
CMD ["apache2ctl", "-D","FOREGROUND"]