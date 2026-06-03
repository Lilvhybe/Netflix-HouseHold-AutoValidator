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

ENTRYPOINT ["sh", "-c", "echo \"email:\n  imap: \\\"${EMAIL_IMAP}\\\"\n  login: \\\"${EMAIL_LOGIN}\\\"\n  password: \\\"${EMAIL_PASSWORD}\\\"\n  mailbox: \\\"${EMAIL_MAILBOX}\\\"\\ntargetFrom: \\\"${TARGET_FROM}\\\"\\ntargetSubject: \\\"${TARGET_SUBJECT}\\\"\" > /app/config.yaml && ./validator"]
