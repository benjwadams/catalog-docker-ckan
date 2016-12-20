FROM ioos/catalog-docker-base

COPY ./contrib/my_init.d /etc/my_init.d

RUN echo "Listen 8080" > /etc/apache2/ports.conf

COPY ./contrib/config/ckan-apache.conf /etc/apache2/sites-available/ckan_default.conf

RUN a2ensite ckan_default
RUN a2dissite 000-default

# Add CKAN reindexing to the cron script.  Note that this needs to have run
# my_init scripts and have the database set up to work, but it is assumed
# that this will happen by the time the cron setup is called
# TODO: eliminate root as crontab user as well as ckan owner
RUN echo '0 * * * * root /usr/lib/ckan/default/bin/paster --plugin=ckan search-index rebuild -q -r --config=/etc/ckan/default/ckan.ini' >> /etc/crontab

CMD ["/sbin/my_init", "--", "/bin/services/ckan/run"]
