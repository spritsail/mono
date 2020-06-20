FROM spritsail/alpine:3.12

ARG MONO_VER=6.8.0.123-r0
ARG MONO_DESC
ARG MONO_PACKAGE

LABEL maintainer="Spritsail <mono@spritsail.io>" \
      org.label-schema.vendor="Spritsail" \
      org.label-schema.name="Mono" \
      org.label-schema.url="https://github.com/spritsail/mono-apk" \
      org.label-schema.description=${MONO_DESC} \
      org.label-schema.version=${MONO_VER} \
      io.spritsail.version.mono=${MONO_VER} \
      io.spritsail.mono.packages="mono-runtime {MONO_PACKAGE}"

RUN echo "https://alpine.spritsail.io/mono" >> /etc/apk/repositories \
 && apk add --no-cache mono-runtime=${MONO_VER} $(echo -n $MONO_PACKAGE | sed -E "s#(\ |$)#=${MONO_VER} #g")
