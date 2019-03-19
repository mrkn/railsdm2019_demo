FROM rubylang/ruby

USER root

# tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini

# fluentd
RUN echo 'gem: --no-document' >> /etc/gemrc && \
    gem install oj -v "3.3.10" && \
    gem install json -v "2.1.0" && \
    gem install fluentd -v "~> 1.3.3" && \
    gem install bigdecimal -v "~> 1.3.5" && \
    rm -rf /usr/local/lib/ruby/gems/*/cache/*.gem

USER ubuntu
ENV HOME=/home/ubuntu

WORKDIR $HOME

ADD fluent.conf fluent/

EXPOSE 24224 5140
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["fluentd", "-c", "fluent/fluent.conf", "-vv"]
