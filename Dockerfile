# Stage 1: Build the Go binary
FROM golang:latest AS builder

# Set the working directory inside the container
WORKDIR /go/src/app

# Copy the local package files to the container's workspace
COPY sample-app .

# Download and install any required dependencies
RUN go get -d -v ./...

# Build the Go binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# Stage 2: Create a minimal image using scratch
FROM scratch

# Copy the built binary from the previous stage
COPY --from=builder /go/src/app/app /app

# Expose port 8888 to the outside world
EXPOSE 8888

# Command to run the executable
CMD ["/app"]
