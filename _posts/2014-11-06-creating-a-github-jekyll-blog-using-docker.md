---
author:		Marcelo Pinheiro
title:		Creating a GitHub Jekyll Blog using Docker
layout:		post
date:		2014-11-06 20:20:00
permalink:	/2014/11/06/creating-a-github-jekyll-blog-using-docker
categories:
  - github
  - jekyll
  - docker
---
Hello everyone,

Let's talk about how to create a blog using Docker running a containerized Jekyll to publish posts on GitHub Pages.

If you don't know, [Jekyll][jekyll] is a famous blog engine written in Ruby that uses [Markdown][markdown] files as blog posts, avoiding use of databases to store stuff. Jekyll is nice due for simplicity: you need only to create a single `.markdown` or `.md` file inside `_posts` directory and run the following command in your terminal to see your blog running:

	$ ruby -S jekyll serve

I've used [Octopress][octopress], a framework written above Jekyll. It's nice, but you have some effort to create blog skeleton and make it working well with [GitHub Pages][githubpages]. I decided to be more simplistic today, changing to Jekyll.

Well, it looks great but where [Docker][docker] enter? Some months ago, I'm moving from [Vagrant][vagrant] to Docker to have more agility because containers are MUCH more thin than entire VM's running in your machine. After some research on the interwebs, I decided to create a blog from scratch using Docker and Jekyll. I will presume that you already know how Docker works and have some contact with `Dockerfile` config files.

At first, you need to create a Dockerfile. Let's see an example:

	FROM	salizzar/centos-7-ruby

	WORKDIR	/root

	RUN	ruby -S gem install jekyll therubyracer

	EXPOSE	4000

It installs `jekyll` and `therubyracer` gems. The Ruby Racer gem is required to build markdown as Html files. To create a Docker image with Jekyll run:

	$ docker build -t myblog .

You probably will see an output similar to this:

	Sending build context to Docker daemon 60.93 kB
	Sending build context to Docker daemon
	Step 0 : FROM salizzar/centos-7-ruby
	 ---> 760b5cd8a959
	Step 2 : WORKDIR /root
	 ---> Using cache
	 ---> c36149f0cadd
	Step 3 : RUN ruby -S gem install jekyll therubyracer
	 ---> Running in a03f0553e865
	Successfully installed liquid-2.6.1
	Successfully installed kramdown-1.5.0
	Building native extensions.  This could take a while...
	(... some gems later ...)
	Installing ri documentation for therubyracer-0.12.1
	34 gems installed
	 ---> ac45b6e4eec3
	Removing intermediate container a03f0553e865
	Step 5 : EXPOSE 4000
	 ---> Running in 33f300b8822c
	 ---> c986a07888b9
	Removing intermediate container 33f300b8822c
	Successfully built c986a07888b9

Now your Docker image with Jekyll is ready to be used. Let's create blog skeleton now:

	$ docker run -it -v `pwd`:/root myblog ruby -S jekyll new . --force

Now check the resulting skeleton:

	$ ls -lh
	total 40
	-rw-r--r--  1 salizzar  staff   101B Nov  6 21:19 Dockerfile
	-rw-r--r--  1 salizzar  staff   350B Nov  6 21:19 _config.yml
	drwxr-xr-x  5 salizzar  staff   170B Nov  6 20:05 _includes
	drwxr-xr-x  5 salizzar  staff   170B Nov  6 20:05 _layouts
	drwxr-xr-x  6 salizzar  staff   204B Nov  6 21:24 _posts
	drwxr-xr-x  5 salizzar  staff   170B Nov  6 20:05 _sass
	drwxr-xr-x  9 salizzar  staff   306B Nov  6 21:21 _site
	-rw-r--r--  1 salizzar  staff   1.5K Nov  6 20:42 about.md
	drwxr-xr-x  3 salizzar  staff   102B Nov  6 20:05 css
	-rw-r--r--  1 salizzar  staff   1.3K Nov  6 20:05 feed.xml
	-rw-r--r--  1 salizzar  staff   506B Nov  6 20:05 index.html

Jekyll will create the structure above. The `--force` parameter forces Jekyll to create skeleton inside a non-empty folder; default behavior will display a error message because it expects to create inside a empty directory.

Now is time to run Jekyll HTTP server to see the magic happening:

	$ docker run -it -v $(pwd):/root -p 4000:4000 myblog \
		ruby -S jekyll serve --host=0.0.0.0 --watch --force_polling

The command above do this:

* Run a interactive TTY from docker (`--it`)

* Mounts current directory inside container at /root (`-v $(pwd):/root`)

* Expose port 4000 from container to host (`-p 4000:4000`)

* Uses `myblog` image to run container

* Ups Jekyll server using `ruby -S jekyll serve`

* Sets Jekyll host to 0.0.0.0 (`--host=0.0.0.0`)

* Forces Jekyll to watch modifications inside blog skeleton (`--watch`)

* Forces Jekyll to polling periodically in order to detect changes (`--force_polling`)

Open your browser and type Docker IP (setted by `DOCKER_HOST` envvar) followed by :4000 (Jekyll HTTP Server port) and you see your blog running on Docker. If you run OSX, type in your terminal:

	$ open `echo $DOCKER_HOST | sed 's/tcp/http/' | sed 's/2376/4000/'`

I recommend you to look at [Jekyll Documentation][jekyll_docs] and [GitHub Pages post explaining how to use Jekyll][githubpages_docs] to configure your personal information inside `_config.yml` file, setting custom templates / add plugins.

[jekyll]: 		http://jekyllrb.com
[markdown]:		http://daringfireball.net/projects/markdown/
[octopress]:		http://octopress.org
[githubpages]:		https://pages.github.com
[docker]:		https://docker.com
[vagrant]:		https://vagrantup.com
[jekyll_docs]:		http://jekyllrb.com/docs/home/
[githubpages_docs]:	https://help.github.com/articles/using-jekyll-with-pages/
