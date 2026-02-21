FROM docker/sandbox-templates:opencode

USER root

COPY agents/* /home/agent/.config/opencode/agents

RUN \
  npm install -g @playwright/cli@latest && \
  playwright-cli install --skils

USER agent
