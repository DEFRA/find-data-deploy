#FROM golang:latest  AS build
FROM golang:1.9.2-alpine3.6 AS builder

# Install tools required to build the project
RUN apk add --no-cache git
RUN go get github.com/golang/dep/cmd/dep

# Gopkg.toml and Gopkg.lock lists project dependencies
COPY ./golang/src/location-lookup/Gopkg.lock ./golang/src/location-lookup/Gopkg.toml /go/src/project/
WORKDIR /go/src/project/

# Install library dependencies
RUN dep ensure -vendor-only

# Only runs when the merged file changes
ADD ./compose/location/data/merged_results.tgz /

# Runs when project files change
COPY ./golang/src/location-lookup/* /go/src/project/
RUN go build -o /bin/project *.go

# This results in a single layer image
FROM golang:1.9.2-alpine3.6
ENV LOCATION_MERGE_FILE=/merged_results.csv
COPY --from=builder /merged_results.csv /
COPY --from=builder /bin/project /bin/project
CMD ["/bin/project"]
