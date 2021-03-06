VERSION := $(shell git describe --tags --always --dirty="-dev")
LDFLAGS := -ldflags='-X "main.Version=$(VERSION)"'

release: gh-release clean dist
	govendor sync
	github-release release \
	--security-token $$GH_LOGIN \
	--user AndreyMarchuk \
	--repo chamber \
	--tag $(VERSION) \
	--name $(VERSION)

	github-release upload \
	--security-token $$GH_LOGIN \
	--user AndreyMarchuk \
	--repo chamber \
	--tag $(VERSION) \
	--name chamber-$(VERSION)-darwin-amd64 \
	--file dist/chamber-$(VERSION)-darwin-amd64

	github-release upload \
	--security-token $$GH_LOGIN \
	--user AndreyMarchuk \
	--repo chamber \
	--tag $(VERSION) \
	--name chamber-$(VERSION)-linux-amd64 \
	--file dist/chamber-$(VERSION)-linux-amd64
	
	github-release upload \
	--security-token $$GH_LOGIN \
	--user AndreyMarchuk \
	--repo chamber \
	--tag $(VERSION) \
	--name chamber-$(VERSION)-windows-amd64 \
	--file dist/chamber-$(VERSION)-windows-amd64

	github-release upload \
	--security-token $$GH_LOGIN \
	--user AndreyMarchuk \
	--repo chamber \
	--tag $(VERSION) \
	--name chamber-$(VERSION).sha256sums \
	--file dist/chamber-$(VERSION).sha256sums

clean:
	rm -rf ./dist
	
linux:
	govendor sync
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build $(LDFLAGS) -o dist/chamber-$(VERSION)-linux-amd64

dist:
	mkdir dist
	govendor sync
	GOOS=darwin GOARCH=amd64 CGO_ENABLED=0 go build $(LDFLAGS) -o dist/chamber-$(VERSION)-darwin-amd64
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build $(LDFLAGS) -o dist/chamber-$(VERSION)-linux-amd64
	GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build $(LDFLAGS) -o dist/chamber-$(VERSION)-windows-amd64
	@which sha256sum 2>&1 > /dev/null || ( \
		echo 'missing sha256sum; install on MacOS with `brew install coreutils && ln -s $$(which gsha256sum) /usr/local/bin/sha256sum`' ; \
		exit 1; \
	)
	cd dist && \
		sha256sum chamber-$(VERSION)-* > chamber-$(VERSION).sha256sums

gh-release:
	go get -u github.com/aktau/github-release

govendor:
	go get -u github.com/kardianos/govendor
