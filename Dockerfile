FROM ruby:2.7.1-buster
RUN apt-get update -qq && apt-get install -y imagemagick 
RUN apt-get install -y build-essential 
RUN mkdir /docker_gxt
WORKDIR /docker_gxt
COPY Gemfile /docker_gxt/Gemfile
COPY Gemfile.lock /docker_gxt/Gemfile.lock
RUN bundle update --bundler
RUN bundle install
COPY . /docker_gxt

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 1792

RUN echo "OKay"
RUN which thin

# Start the main process.
# CMD ["bundle", "exec", "ruby", "server.rb"]


