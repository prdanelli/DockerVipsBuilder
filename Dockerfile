FROM debian:buster-slim

ARG VIPS_VERSION=8.9.1
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download

COPY ./Aptfile /tmp/Aptfile

RUN apt-get update \
	&& apt-get install -y $(cat /tmp/Aptfile | xargs)

RUN echo 'Install mozjpeg' \
	&& cd /tmp \
    && git clone git://github.com/mozilla/mozjpeg.git \
    && cd /tmp/mozjpeg \
    && git checkout v3.3.1 \
    && autoreconf -fiv \
    && ./configure --prefix=/usr \
    && make install

RUN cd /usr/src \
	&& wget ${VIPS_URL}/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz \
	&& tar xzf vips-${VIPS_VERSION}.tar.gz \
	&& cd vips-${VIPS_VERSION} \
	&& export PKG_CONFIG_PATH=/usr/local/vips/lib/pkgconfig \
	&& ./configure --prefix=/usr/local/vips --disable-gtk-doc \
	&& make \
	&& make install

# clean the build area and make a tarball ready for packaging
RUN echo 'Cleaning up' \
	&& cd /usr/local/vips \
	&& rm bin/batch_* bin/vips-8.9 \
	&& rm bin/vipsprofile bin/light_correct bin/shrink_width \
	&& strip lib/*.a lib/lib*.so* \
	&& rm -rf share/gtk-doc \
	&& rm -rf share/man \
	&& rm -rf share/thumbnailers \
	&& cd /usr/local \
	&& tar cfz libvips-dev.tar.gz vips

RUN echo "Testing" \
	&& export LD_LIBRARY_PATH=/usr/local/vips/lib \
	&& gem install ruby-vips \
	&& ruby -e 'require "ruby-vips"; puts "success!"'

# Clean up
RUN echo 'Cleaning up build tools' \
	&& apt-get remove -y $(cat /tmp/Aptfile | xargs) \
	&& apt autoremove -y
