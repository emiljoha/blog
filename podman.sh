podman build . --build-arg WEBSITE_BASE_URL="http://localhost:8080" -t blog-hugo
podman run blog-hugo --ports 8080:80
