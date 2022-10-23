FROM golang:alpine as builder

WORKDIR /usr/src

RUN apk add --no-cache git upx openssl && \
  git clone --depth 1 https://github.com/cnsilvan/UnblockNeteaseMusic.git . && \
  CurrentVersion=$(git rev-parse --short HEAD) && \
  Project=github.com/cnsilvan/UnblockNeteaseMusic && \
  Path="$Project/version" && \
  GitCommit=$(git rev-parse --short HEAD || echo unsupported) && \
  GoVersion=$(go version) && \
  BuildTime=$(TZ=UTC+8 date "+%Y-%m-%d %H:%M:%S") && \
  TargetDir="bin" && \
  ExecName="UnblockNeteaseMusic" && \
  env CGO_ENABLED=0 go build -ldflags \ "-X '$Path.Version=$CurrentVersion' -X '$Path.BuildTime=$BuildTime' -X '$Path.GoVersion=$GoVersion' -X '$Path.GitCommit=$GitCommit' -w -s" -o $TargetDir/$ExecName && \
  ./createCertificate.sh && cp -f ca.crt createCertificate.sh server.crt server.key -t $TargetDir


FROM golang:alpine

WORKDIR /app

RUN apk --no-cache add ca-certificates

COPY --from=builder /usr/src/bin .

CMD ["/app/UnblockNeteaseMusic"]