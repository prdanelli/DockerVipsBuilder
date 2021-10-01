# Vips Builder
Minimal VIPS Docker image based on Debian Buster Slim

## Usage

```docker
FROM prdanelli/vips-builder:latest as vips-builder

COPY --from=vips-builder /usr/local/libvips-dev.tar.gz /usr/local/
ENV VIPSHOME /usr/local/vips
ENV PATH $VIPSHOME/bin:$PATH
ENV LD_LIBRARY_PATH $VIPSHOME/lib:$LD_LIBRARY_PATH
ENV PKG_CONFIG_PATH $VIPSHOME/lib/pkgconfig:$PKG_CONFIG_PATH

RUN cd /usr/local/ \
	&& tar -xvzf libvips-dev.tar.gz \
	&& rm -f libvips-dev.tar.gz \
	&& pkg-config vips --cflags
```
