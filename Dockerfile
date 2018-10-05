ROM java:8-jre
#https://github.com/docker-library/tomcat

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH

RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

# see https://www.apache.org/dist/tomcat/tomcat-8/KEYS
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys \
    05AB33110949707C93A279E3D3EFE6B686867BA6 \
    07E48665A34DCAFAE522E5E6266191C37C037D42 \
    47309207D818FFD8DCD3F83F1931D684307A10A5 \
    541FBE7D8F78B25E055DDEE13C370389288584E7 \
    61B832AC2F1C5A90F0F9B00A1C506407564C17A3 \
    79F7026C690BAA50B92CD8B66A3AD3F4F22C4FED \
    9BA44C2621385CB966EBA586F72C284D731FABEE \
    A27677289986DB50844682F8ACB77FC2E86E29AC \
    A9C5DF4D22E99998D9875A5110C01C5A2F6059E7 \
    DCFD35E0BF8CA7344752DE8B6FB21E8933C60243 \
    F3A04C595DB5B6A5F1ECA43E3B7BBB100D811BBE \
    F7DA48BB64BCB84ECBA7EE6935CD23C10D498E23

ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.0.32
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN set -x \
    && curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
    && curl -fSL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
    && gpg --verify tomcat.tar.gz.asc \
    && tar -xvf tomcat.tar.gz --strip-components=1 \
    && rm bin/*.bat \
    && rm tomcat.tar.gz*

ADD ./target/*.war $CATALINA_HOME/webapps/

EXPOSE 8080
CMD ["catalina.sh", "run"]
Update Manifest
There is one change to the distelli-manifest.yml that needs to be made. Clone your repository on your local machine, and open the distelli-manifest.yml in the text editor of your choice. At the top of the file change the username to your Pipelines username and make sure the application name is correct as well.

<b>DISTELLI USERNAME</b>/tomcat-war-docker:

  Env:
    # Set the below enviornment variables for your environment
    - CATALINA_HOME: "/usr/local/tomcat"
    # The port number below is only for reference. Set it to the port number of your tomcat server.
    - PORT: "8080"

  Build:
    - echo "DD_USERNAME- $DISTELLI_DOCKER_USERNAME"
    - echo "DD_EMAIL-    $DISTELLI_DOCKER_EMAIL"
    - echo "DD_ENDPOINT- $DISTELLI_DOCKER_ENDPOINT"
    - mvn package
    ### Docker Build Commands ###
    - docker login -u "$DISTELLI_DOCKER_USERNAME" -p "$DISTELLI_DOCKER_PW" $DISTELLI_DOCKER_ENDPOINT
    - docker build --quiet=false -t "$DISTELLI_DOCKER_REPO" $DISTELLI_DOCKER_PATH
    - docker tag "$DISTELLI_DOCKER_REPO" "$DISTELLI_DOCKER_REPO:$DISTELLI_BUILDNUM"
    - docker push "$DISTELLI_DOCKER_REPO:$DISTELLI_BUILDNUM"
    ### End Docker Build Commands ###

  PkgInclude:
    - './target/*.war'

  PreInstall:
    - echo "DD_USERNAME- $DISTELLI_DOCKER_USERNAME"
    - echo "DD_EMAIL-    $DISTELLI_DOCKER_EMAIL"
    - echo "DD_ENDPOINT- $DISTELLI_DOCKER_ENDPOINT"
    ### Docker Pre Install Commands ###
    - sudo /usr/bin/docker login -u "$DISTELLI_DOCKER_USERNAME" -p "$DISTELLI_DOCKER_PW" "$DISTELLI_DOCKER_ENDPOINT"
    ### End Docker Pre Install Commands ###

  PostInstall:
    - publicip=$(curl -s ident.me)
    - echo "Public IP $publicip"
    - 'echo "You can validate the install by pointing your browser at http://$publicip:$PORT/SimpleTomcatWebApp"'
    
  Exec:
    #- cid=$(uuidgen)
    #- trap 'sudo docker stop $cid' SIGTERM
    #- sudo docker run --name=$cid --rm=true $DISTELLI_DOCKER_PORTS  "$DISTELLI_DOCKER_REPO:$DISTELLI_BUILDNUM" &
    #- wait
    #- 'true'
     - sudo docker run --rm=true $DISTELLI_DOCKER_PORTS "$DISTELLI_DOCKER_REPO:$DISTELLI_BUILDNUM"
