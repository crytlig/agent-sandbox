FROM docker/sandbox-templates:shell-docker

USER root

RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
  #   xvfb       -> virtual X display server (Xvfb)
  #   xauth      -> X authority cookie management
  #   x11vnc     -> VNC server for the virtual display
  #   novnc      -> browser-based VNC client (served from /usr/share/novnc)
  #   websockify -> WebSocket-to-TCP proxy for noVNC
  && apt-get install -y --no-install-recommends \
        xvfb \
       xauth \
       x11vnc \
       novnc \
       websockify \
       fd-find \
  && rm -rf /var/lib/apt/lists/*

USER agent
WORKDIR /home/agent/workspace

# browsers are cached under ~/.cache/ms-playwright.
RUN npm install -g --ignore-scripts playwright \
  && sudo env "PATH=$PATH" playwright install-deps chromium \
  && playwright install chromium


# install claude
RUN \
  curl -fsSL https://claude.ai/install.sh | bash

# install pi
RUN \
  npm install -g --ignore-scripts @earendil-works/pi-coding-agent

ENV PATH="/home/agent/.local/bin:${PATH}"

CMD ["bash"]
