FROM ruby:2.2

RUN gem install travis
RUN gem install json -v 1.8.3
RUN gem install bundler

RUN mkdir ~/.travis
RUN git clone https://github.com/travis-ci/travis-build.git ~/.travis/travis-build
RUN cd ~/.travis/travis-build && \
  bundle install && bundle exec rspec spec
