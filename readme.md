# Ruby packaging for AppImage

This repository contains an example on how you can package the Ruby application into portable [AppImage](https://appimage.org/). The script downloads the Ruby source code, compiles it, modifies for AppImage building and executes the build. The resulting file will be placed into the `out` subdirectory of the parent folder.

The script does not configure the localhost environment for building the image. For that please use instructions provided by the [rbenv/ruby-build](https://github.com/rbenv/ruby-build/wiki) projects.

The work of the script was tested on Ubuntu 14.04. Resulting AppImages are successfully run on current stable releases of Ubuntu, Debian, Mint, CentOS and Fedora.

In order to use the script just clone the repository and run `./gen_appimage.sh`.

## Bundling the gems and ruby applications into the appimage

The script can be used to bundle external applications that require Ruby. An example script to bundle [adsf](https://github.com/ddfreyne/adsf/) gem and it's executable as the starting point of the AppImage can be found in `examples` directory. In order to build the AppImage just run `./build_adsf.sh` in the `examples` directory.

In order to create AppImage with custom Ruby application you should:

* Create application.desktop file that will run the application.
* Create application.png file for the bundle.
* Create application.sh file that will copy contents of the application to the $APP_DIR directory.
* Create application executable in $APP_DIR/usr/bin directory and insert correct header with `insert_run_header` function, if neccessary.
* Run the `gen_appimage.sh` passing the name of the application and it's version as arguments from the directory containing .desktop, .png and .sh files: `./gen_appimage.sh application 1.0`.
