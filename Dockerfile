FROM golang:3.12-alpine

WORKDIR /go/src/app
COPY ./*.go ./


RUN go get -d -v ./...
RUN go install -v ./...

EXPOSE 5000

CMD ["app"]
