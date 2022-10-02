---
title: Development Environment Guide
name: software
---

## Getting set up

In this course, we'll be using C++ and a few associated libraries, alongside CMake as our primary build tool. We use Docker containers to ensure a standardized environment between all students. To get started, go through the Development Environment setup portion of this [cs300 lab](https://cs.brown.edu/courses/csci0300/2022/assign/labs/lab0.html), except clone the following repo instead of theirs: `https://github.com/BrownAppliedCryptography/devenv.git`. After entering the container, you should be good to go; if `cmake` isn't found, fun the following command:

```bash
sudo apt-get install\
  cmake\
  libssl-dev\
  libboost-all-dev\
  doctest-dev\
  doxygen
```
