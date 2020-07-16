FROM golang:alpine:3.12

WORKDIR /go/src/app
COPY ./*.go ./


RUN go get -d -v ./...
RUN go install -v ./...

EXPOSE 5000

CMD ["app"]
