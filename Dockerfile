FROM ruby:3.1.3-buster
RUN apt-get update -qq && apt-get install -y imagemagick
RUN apt-get install -y build-essential 

RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list \
 && sed -i '/security.debian.org/d' /etc/apt/sources.list \
 && apt-get update -qq \
 && apt-get install -y curl \
 && curl -sL https://deb.nodesource.com/setup_18.x | bash - \
 && apt-get install -y nodejs
 
RUN mkdir /docker_gxt
WORKDIR /docker_gxt
COPY Gemfile /docker_gxt/Gemfile
COPY Gemfile.lock /docker_gxt/Gemfile.lock
RUN gem install bundler -v 2.2.21
# RUN bundle update --bundler
RUN bundle install
COPY . .

# Add a script to be executed every time the container starts.
#COPY entrypoint.sh /usr/bin/
#RUN chmod u+x /usr/bin/entrypoint.sh
#ENTRYPOINT ["entrypoint.sh"]
EXPOSE 1792

RUN echo "OKay"
RUN which thin

# Start the main process.
# CMD ["bundle", "exec", "ruby", "server.rb"]
