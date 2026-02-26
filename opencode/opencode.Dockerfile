FROM docker/sandbox-templates:opencode

USER root

WORKDIR /home/agent

COPY agents/* /home/agent/.config/opencode/agents/

RUN \
  npm install -g @playwright/cli@latest && \
  playwright-cli install --skils

RUN \
   install -dm 755 /etc/apt/keyrings && \
  curl -fSs https://mise.jdx.dev/gpg-key.pub | tee /etc/apt/keyrings/mise-archive-keyring.asc 1> /dev/null && \
  echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.jdx.dev/deb stable main" |  tee /etc/apt/sources.list.d/mise.list && \
  apt update -y && \
  apt install -y mise 

COPY template.mise.toml /home/agent/mise.toml

USER agent

RUN mise trust -a

RUN mise up
RUN echo 'eval "$(/usr/bin/mise activate bash)"' >> ~/.bashrc

