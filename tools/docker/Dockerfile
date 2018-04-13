FROM ubuntu:16.04
LABEL maintainer="Martin Thomson <martin.thomson@gmail.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates coreutils curl git make ssh libxml2-utils xsltproc \
    python3-minimal python3-lxml python3-pip python3-setuptools python3-wheel \
    mmark ruby default-jre libsaxonb-java gcc autoconf automake \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get autoremove -y && apt-get clean -y

ENV USER idci
ENV LOGNAME $USER
ENV HOSTNAME $USER
ENV HOME /home/$USER
ENV SHELL /bin/bash

RUN useradd -d "$HOME" -s "$SHELL" -m "$USER"
WORKDIR $HOME
USER $USER

ENV BINDIR $HOME/bin
RUN mkdir -p $BINDIR
ENV PATH $BINDIR:/usr/local/bin:/usr/bin:/bin

RUN set -e; tool_install() { \
      tool="$1";version="$2";sha="$3"; tmp=$(mktemp -t "${tool}XXXXX.tgz"); \
      curl -sSLf "https://tools.ietf.org/tools/${tool}/${tool}-${version}".tgz -o "$tmp"; \
      [ $(sha256sum -b "$tmp" | cut -d ' ' -f 1 -) = "$sha" ]; \
      target="${BINDIR:-~/.local/bin}/${tool}"; \
      tar xzfO "$tmp" "${tool}-${version}/${tool}" >"$target"; rm -f "$tmp"; \
      chmod 755 "$target"; }; \
    tool_install idnits 2.15.00 \
    f655d06e7d3b1c35d7ca55f91243115359ae4fdd17553ea58a301091a07ed7ac && \
    tool_install rfcdiff 1.45 \
    82e449b7ee887074302b2050e41fc60d4b3bbec8c20e05ce2d7fab81b332771e

RUN pip3 install --user --compile xml2rfc && \
    ln -s $HOME/.local/bin/xml2rfc $BINDIR
RUN gem install --no-doc --user-install --bindir $BINDIR \
    certified kramdown-rfc2629 && \
    certified-update

ENV KRAMDOWN_REFCACHEDIR=$HOME/.cache/xml2rfc
RUN mkdir -p $KRAMDOWN_REFCACHEDIR

RUN GIT_REFERENCE=$HOME/git-reference; \
    git init $GIT_REFERENCE; \
    git -C $GIT_REFERENCE remote add i-d-template https://github.com/martinthomson/i-d-template; \
    git -C $GIT_REFERENCE remote add rfc2629xslt https://github.com/reschke/xml2rfc; \
    git -C $GIT_REFERENCE fetch --all
