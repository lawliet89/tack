FROM golang:1.8.3-stretch as go_builder

WORKDIR /build
RUN set -uex \
    && go get -u github.com/cloudflare/cfssl/cmd/cfssl

FROM python:3.5
ARG AWS_CLI_VERSION=1.11.129
ARG JQ_VERSION=1.5
ARG KUBERNETES_VERSION=1.7.3
ARG TERRAFORM_VERSION=0.10.0

WORKDIR /tmp
COPY --from=go_builder /go/bin/cfssl /usr/local/bin
RUN set -uex \
    && chmod +x /usr/local/bin/cfssl \
    && pip install "awscli==${AWS_CLI_VERSION}" \
    && curl -sSL "https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64" -o /usr/local/bin/jq \
    && chmod +x /usr/local/bin/jq \
    && curl -sSL "https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && apt-get update \
    && apt-get install -y unzip \
    && curl -SSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip \
    && unzip terraform.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/terraform \
    && rm terraform.zip \
    && apt-get remove -y unzip


WORKDIR /tack
COPY ./ ./

# Sanity check
RUN make prereqs
