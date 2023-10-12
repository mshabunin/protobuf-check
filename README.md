This repository helps to test OpenCV compatibility with protobuf.

Several variants and versions are being tested:
* own - use built-in protobuf
* system - use protobuf from the Ubuntu 22.04 packages
* custom - use manually built protobuf (versions 3.20.3 - 24.4, static/dynamic)

Dependencies: docker

Expected directory structure:
* _opencv/_
* _opencv_contrib/_ (not used yet)
* _opencv_extra/_ (not used yet)
* _protobuf-check/_ (**this repository**)
  * _workspace/_ (directory containing all builds and logs)
  * _scripts/_ (build scripts which will be run inside docker containers)
  * _run.sh_ (run this script to do testing)
