FROM jvanzyl/mrel:11.0.8
MAINTAINER "Jason van Zyl" <jason@vanzyl.ca>

COPY ./entrypoint.sh /entrypoint.sh
COPY ./settings.xml /settings.xml
COPY ./maven.bash /maven.bash

ENTRYPOINT ["/entrypoint.sh"]
