# Ruby packaging for AppImage

This repository contains an example on how you can package the Ruby application into portable [AppImage](https://appimage.org/). The script downloads the Ruby source code, compiles it, modifies for AppImage building and executes the build. The resulting file will be placed into the `out` subdirectory of the parent folder.

The script does not configure the localhost environment for building the image. For that please use instructions provided by the [rbenv/ruby-build](https://github.com/rbenv/ruby-build/wiki) projects.

The work of the script was tested on Ubuntu 14.04. Resulting AppImages are successfully run on current stable releases of Ubuntu, Debian, Mint, CentOS and Fedora.

In order to use the script just clone the repository and run `./gen_appimage.sh`.
