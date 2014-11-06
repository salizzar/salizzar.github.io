FROM	salizzar/centos-7-ruby

WORKDIR	/root

RUN	ruby -S gem install jekyll therubyracer

EXPOSE	4000
