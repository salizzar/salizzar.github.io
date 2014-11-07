Habemvs Epiphania
=================

Welcome to my personal blog. Here is the Jekyll base skeleton with raw posts in Markdown with a Dockerfile, ready to create a Docker image.

To create Docker image:

	$ docker build -t salizzar.github.io .

To run Jekyll server:

	$ docker run -it -v `pwd`:/root -p 4000:4000 salizzar.github.io ruby -S bundle exec jekyll serve --host=0.0.0.0 --watch --force_polling

