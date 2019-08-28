FROM gapsystem/gap-docker

MAINTAINER Michael Torpey <mct25@st-andrews.ac.uk>

COPY --chown=1000:1000 binder $HOME/demos

RUN sudo pip3 install ipywidgets RISE

RUN jupyter-nbextension install rise --user --py

RUN jupyter-nbextension enable rise --user --py

USER gap

WORKDIR $HOME/demos/notebooks
