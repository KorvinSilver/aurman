# arch image with base-devel
FROM base/devel

# create user and set sudo priv
RUN useradd -m aurman -s /bin/bash
RUN echo 'aurman ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# switch user and workdir
USER aurman
WORKDIR /home/aurman

# multilib
RUN sudo sh -c "sed -i '/\[multilib\]/,/Include/s/^[ ]*#//' /etc/pacman.conf"

# aurman
RUN sudo pacman --needed --noconfirm -Syu python expac python-requests pyalpm pacman sudo git python-regex
ADD . /home/aurman/aurman-git
WORKDIR /home/aurman/aurman-git
RUN sudo python setup.py install --optimize=1
WORKDIR /home/aurman
RUN sudo rm -rf aurman-git/

# makepkg
RUN sudo sh -c "sed -i '/MAKEFLAGS=/s/^.*$/MAKEFLAGS=\"-j\$(nproc)\"/' /etc/makepkg.conf"
RUN sudo sh -c "sed -i '/PKGEXT=/s/^.*$/PKGEXT=\".pkg.tar\"/' /etc/makepkg.conf"

# include tests
COPY src/unit_tests/tests_to_execute.sh /home/aurman
RUN sudo chown aurman tests_to_execute.sh
RUN chmod +x tests_to_execute.sh
ENTRYPOINT /home/aurman/tests_to_execute.sh