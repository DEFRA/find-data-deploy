FROM golang:latest

# Install tools required to build the project
RUN apt-get install -y git
RUN go get github.com/golang/dep/cmd/dep

# Gopkg.toml and Gopkg.lock lists project dependencies
RUN mkdir /go/src/location-lookup
COPY ./services/golang/location-lookup/Gopkg.lock ./services/golang/location-lookup/Gopkg.toml /go/src/location-lookup/
WORKDIR /go/src/location-lookup/

# Install library dependencies
RUN dep ensure -vendor-only

# Only runs when the merged file changes
ADD ./compose/location/data/merged_results.csv /

# Runs when project files change
COPY ./services/golang/location-lookup/* /go/src/location-lookup/
RUN go build -o /bin/project *.go

# This results in a single layer image
ENV LOCATION_MERGE_FILE=/merged_results.csv

CMD ["/bin/project"]
