FROM python:3.6-slim


## Install optional dependencies
# Voikko
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		libvoikko1 \
		voikko-fi \
	&& rm -rf /var/lib/apt/lists/*

# fasttext
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		build-essential \
	&& pip install --no-cache-dir \
		cython \
	&& rm -rf /var/lib/apt/lists/*

# Vowpal Wabbit. Using old VW because 8.5 links to wrong Python version
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		libboost-program-options-dev \
		zlib1g-dev \
		libboost-python-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& dpkg -P --force-all python2.7 python2.7-dev python2.7-minimal \
	&& rm -rf ./usr/lib/python2.7* ./usr/bin/python2.7 ./usr/lib/x86_64-linux-gnu/libpython2.7.so.1.0


## Install pipenv and Annif
# Using old pip version because --no-cache-dir doesn't seem to work in 19.1.1
RUN pip install --upgrade pip==18.1 \
	&& pip install pipenv --no-cache-dir \
	&& rm -rf /root/.cache/pip*/*

# Files needed by pipenv install:
COPY Pipfile Pipfile.lock README.md setup.py /Annif/
WORKDIR /Annif

# TODO Handle occasional timeout in nltk.downloader leading failed build
# TODO Disable caching in pipenv, maybe EXPORT PIP_NO_CACHE_DIR=false
RUN pipenv install --system --deploy --ignore-pipfile \
	&& python -m nltk.downloader punkt \
    && pip install --no-cache-dir \
    	annif[voikko] \
		fasttextmirror \
		vowpalwabbit==8.4 \
	&& rm -rf /root/.cache/pip*/*

COPY annif annif

CMD annif
