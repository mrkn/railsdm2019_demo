FROM rubylang/ruby

USER root

# tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini

# Python and Apache Arrow

RUN apt update && \
    apt install -y --no-install-recommends \
        apt-transport-https \
        cmake \
        curl \
        lsb-release \
        python3.6-dev \
        python3-pip \
        python3-setuptools && \
    curl -sfSL -o /usr/share/keyrings/apache-arrow-keyring.gpg \
         https://dl.bintray.com/apache/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/apache-arrow-keyring.gpg \
    && { \
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/apache-arrow-keyring.gpg] https://dl.bintray.com/apache/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/ $(lsb_release --codename --short) main"; \
        echo "deb-src [signed-by=/usr/share/keyrings/apache-arrow-keyring.gpg] https://dl.bintray.com/apache/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/ $(lsb_release --codename --short) main"; \
    } >> /etc/apt/sources.list.d/apache-arrow.list && \
    apt update && \
    apt install -y --no-install-recommends \
        libarrow-dev \
        libarrow-glib-dev \
        libarrow-python-dev \
        libplasma-dev \
        libplasma-glib-dev \
        libgandiva-dev \
        libgandiva-glib-dev \
        libparquet-dev \
        libparquet-glib-dev \
        libgirepository1.0-dev \
        && \
    \
    pip3 install pandas \
                 scikit-learn && \
    pip3 install --no-binary :all: Cython && \
    pip3 install --no-binary :all: pyarrow && \
    \
    rm -rf /var/lib/apt/lists/*

# Gems
RUN echo 'gem: --no-document' >> /etc/gemrc && \
    gem install oj -v "3.3.10" && \
    gem install json -v "2.1.0" && \
    gem install fluentd -v "~> 1.3.3" && \
    gem install bigdecimal -v "~> 1.3.5" && \
    gem install pycall \
                red-arrow \
                # red-arrow-pycall \
                && \
    rm -rf /usr/local/lib/ruby/gems/*/cache/*.gem

RUN git clone -b extpp_and_arrow_0_12 \
        https://github.com/mrkn/red-arrow-pycall.git \
        /tmp/red-arrow-pycall && \
    cd /tmp/red-arrow-pycall && \
    bundle install && \
    rake install

USER ubuntu
ENV HOME=/home/ubuntu

WORKDIR $HOME

ADD fluent.conf fluent/
ADD plugin/* fluent/plugin/

EXPOSE 24224 5140
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["fluentd", "-c", "fluent/fluent.conf", "-p", "fluent/plugin"]
