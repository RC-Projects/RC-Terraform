FROM openjdk:8

RUN mkdir /opt/mule
RUN wget https://repository.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/4.2.1/mule-standalone-4.2.1.tar.gz \
&& tar xvzf mule-standalone-4.2.1.tar.gz -C /opt
RUN echo "de730172857f8030746c40d28e178446 /mule-standalone-4.2.1.tar.gz" | md5sum -c
RUN rm mule-standalone-4.2.1.tar.gz
RUN ln -s /opt/mule-standalone-4.2.1 /opt/mule 

CMD [ "/opt/mule-standalone-4.2.1/bin/mule" ]