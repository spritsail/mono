FROM spritsail/alpine:3.8 AS mono

WORKDIR /output
 
RUN apk --repository "http://dl-cdn.alpinelinux.org/alpine/edge/testing" \
        --no-cache add mono ca-certificates \
 && cert-sync --quiet /etc/ssl/certs/ca-certificates.crt

RUN mkdir -p usr/bin usr/lib/mono/4.5 usr/share/.mono etc \
 && cp -r /etc/mono etc/ \
 && cp -r /usr/share/.mono/* usr/share/.mono \
 && cp -r /usr/bin/mono-sgen usr/bin/mono \
 && cp -r /usr/lib/libmono-btls-shared.so /usr/lib/libMonoPosixHelper.so usr/lib \
 && cp -r /usr/lib/mono/4.5/*.dll usr/lib/mono/4.5 \
 && cp -r /usr/lib/mono/4.5/Facades usr/lib/mono/4.5 \
 && cp -r /usr/lib/mono/gac usr/lib/mono \
 && rm -r usr/lib/mono/4.5/Microsoft.CodeAnalysis* \
	  usr/lib/mono/gac/RabbitMQ.Client \
 && find usr/lib/mono/gac -iname '*.pdb' -delete

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###

FROM spritsail/alpine:3.8

COPY --from=mono /output/ /
