FROM python:3.7.0-alpine
LABEL maintainer="Dmytro Serdiuk <dmytro.serdiuk@gmail.com>" \
    homepage=https://github.com/extsoft/numbers-api
ENV THEUSER="thenumbers" THEHOME="/home/thenumbers"
WORKDIR ${THEHOME}
RUN apk add --no-cache curl && \
    python -m pip install --no-cache-dir --upgrade pip && \
    addgroup -S -g 1000 ${THEUSER} && \
    adduser -S -u 1000 -h ${THEHOME} -G ${THEUSER} ${THEUSER}
USER ${THEUSER}
EXPOSE 5000
COPY --chown=${THEUSER}:${THEUSER} entry.sh ./
ENTRYPOINT ["./entry.sh"]
HEALTHCHECK --interval=5s --timeout=2s --retries=3 \
    CMD curl --silent --fail localhost:5000/random || exit 1
COPY --chown=${THEUSER}:${THEUSER} requirements.txt ./
ENV PATH="${THEHOME}/.local/bin:${PATH}"
RUN python -m pip install --user --no-cache-dir -r requirements.txt && \
    rm requirements.txt
COPY --chown=${THEUSER}:${THEUSER} thenumbers thenumbers
