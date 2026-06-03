FROM golang:alpine AS builder
RUN apk add --no-cache git
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o validator ./cmd/main.go

FROM alpine:latest
RUN apk add --no-cache chromium
WORKDIR /app
COPY --from=builder /app/validator .

ENTRYPOINT ["sh", "-c", "printf 'email:\\n  imap: \"%s\"\\n  login: \"%s\"\\n  password: \"%s\"\\n  mailbox: \"%s\"\\ntargetFrom: \"%s\"\\ntargetSubject: \"%s\"\\n' \"$EMAIL_IMAP\" \"$EMAIL_LOGIN\" \"$EMAIL_PASSWORD\" \"$EMAIL_MAILBOX\" \"$TARGET_FROM\" \"$TARGET_SUBJECT\" > /app/config.yaml && exec ./validator"]
