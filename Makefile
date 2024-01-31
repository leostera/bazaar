deploy:
	docker build . -t registry.fly.io/bazaar:linux-x86_64-$(shell date +%s)
	docker push registry.fly.io/bazaar:linux-x86_64-$(shell date +%s)
	~/.fly/bin/fly deploy -i registry.fly.io/bazaar:linux-x86_64-$(shell date +%s)
