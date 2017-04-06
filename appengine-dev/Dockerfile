FROM python:2

RUN apt-get update && apt-get install -y wget unzip

RUN mkdir -p /ae

WORKDIR /ae

RUN wget https://storage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.52.zip

RUN unzip google_appengine_1.9.52.zip

ENV PATH="${PATH}:/ae/google_appengine"

