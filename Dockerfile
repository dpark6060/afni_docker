FROM ubuntu:18.04

RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository universe && apt-get update

# Install dependencies
RUN apt-get install -y tcsh xfonts-base python-qt4       \
                        gsl-bin netpbm gnome-tweak-tool   \
                        libjpeg62 xvfb xterm vim curl     \
                        gedit evince eog                  \
                        libglu1-mesa-dev libglw1-mesa     \
                        libxm4 build-essential            \
                        libcurl4-openssl-dev libxml2-dev  \
                        libssl-dev libgfortran3           \
                        gnome-terminal nautilus           \
                        gnome-icon-theme-symbolic         \
                        firefox xfonts-100dpi
      
# Install AFNI binaries                  
RUN ln -s /usr/lib/x86_64-linux-gnu/libgsl.so.23 /usr/lib/x86_64-linux-gnu/libgsl.so.19
RUN cd && curl -O https://afni.nimh.nih.gov/pub/dist/bin/linux_ubuntu_16_64/@update.afni.binaries && \
    tcsh @update.afni.binaries -package linux_ubuntu_16_64  -do_extras

# Install R (Fuck R)
# Need to set this or else R wants input from you
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME="/root"
RUN export R_LIBS=$HOME/R && \
    mkdir  $R_LIBS && \
    echo  'setenv R_LIBS ~/R'     >> ~/.cshrc && \
    echo  'export R_LIBS=$HOME/R' >> ~/.bashrc && \
    curl -O https://afni.nimh.nih.gov/pub/dist/src/scripts_src/@add_rcran_ubuntu_18.04.tcsh
ENV PATH="${PATH}:${HOME}/abin"

RUN /bin/bash -c "source ~/.bashrc" && tcsh @add_rcran_ubuntu_18.04.tcsh
RUN rPkgsInstall -pkgs ALL
RUN Rscript -e 'install.packages("devtools",dependencies = TRUE)'
RUN Rscript -e 'require(devtools);install_version("mvtnorm",version = "1.0-8", repos="https://cloud.r-project.org/")'
RUN Rscript -e 'require(devtools);install_version("multcomp", version="1.4-8", repos="https://cloud.r-project.org/")'
RUN Rscript -e 'require(devtools);install_version("modeltools", version="0.2-21", repos="https://cloud.r-project.org/")'
RUN Rscript -e 'require(devtools);install_version("coin", version="1.2-2", repos="https://cloud.r-project.org/",dependencies=FALSE)'
RUN Rscript -e 'require(devtools);install_version("libcoin",version = "1.0-5", repos="https://cloud.r-project.org/")'
RUN Rscript -e 'require(devtools);install_version("emmeans",version = "1.4.4", repos="https://cloud.r-project.org/")'
RUN Rscript -e 'require(devtools);install_version("cowplot",version = "0.9.2", repos="https://cloud.r-project.org/")'
RUN Rscript -e 'require(devtools);install_version("pbkrtest",version = "0.4-7", repos="https://cloud.r-project.org/")'
RUN Rscript -e 'require(devtools);install_version("car",version = "3.0-2", repos="https://cloud.r-project.org/")'
RUN Rscript -e 'install.packages("afex",dependencies = TRUE)'

RUN Rscript -e 'install.packages("phia",dependencies = TRUE)'
RUN Rscript -e 'require(devtools);install_version("brms",version = "2.8.0", repos="https://cloud.r-project.org/")'
RUN Rscript -e 'require(devtools);install_version("metafor",version = "1.9-9", repos="https://cloud.r-project.org/")'

RUN Rscript -e 'install.packages("snow",dependencies = TRUE)'
RUN Rscript -e 'install.packages("paran",dependencies = TRUE)'
RUN Rscript -e 'install.packages("corrplot",dependencies = TRUE)'


# Make afni/suma profiles
RUN cp $HOME/abin/AFNI.afnirc $HOME/.afnirc && suma -update_env

# Prepare for bootcamp.  idk it's just code AFNI needs
RUN curl -O https://afni.nimh.nih.gov/pub/dist/edu/data/CD.tgz && \
    tar xvzf CD.tgz && \
    cd CD && \
    tcsh s2.cp.files . ~ && \
    cd ..
    
RUN apsearch -update_all_afni_help
RUN afni_system_check.py -check_all