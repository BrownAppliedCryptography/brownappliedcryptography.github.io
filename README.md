# CSCI 1515 - Website

## Getting Started

This website is built using [Goo](https://github.com/n-young/goo). Ensure that you have Goo installed to build it. To install Goo, run `go install -v github.com/n-young/goo/cmd/goo@latest`.

Unless you REALLY know what you are doing, use the Makefile to build. There are two main commands; `build` and `serve`. You should always run `make build` before pushing.

To manually build the website, run `go install -v github.com/n-young/goo/cmd/goo@latest`, then `goo build site.yaml`. The site wil be exported to the `build/` directory. See the Goo documentation for information on how to use it.


## File Structure

Goo is a non-opinionated static site generator, but we follow a specific convention to help reduce confusion.

The `./` directory contains a Makefile with targets to build.

The `./views` directory contains HTML templates in Goo format. Nothing interesting here, read Goo documentation to get a sense of how they work.

The `./static` directory is where web content lives; all of these files will be directly copied into the build. We have css, js, images, and files.

The `./src` folder is where Goo pulls information to build the website from. The `data` subfolder is where tabular information is stored, i.e. lectures dates. These are embeded into the home page according to Goo's templating logic. The `docs` subfolder is where page content is stored, i.e. handouts and guides.

The `./build` directories is where the website builds are served from. This folder must not be .gitignore'd since it needs to be in the repository for Netlify to work.


## Documents

Each document follows the same structure. At the top, we have front matter which looks like:

```md
---
title: Tail Recursion
name: tail_recursion
draft: "true"
---
```

The `title` field will be the HTML title when compiled. The `name` field must match up with the file name. The `due` field indicates on the PDF when the assignment is due. The `draft` field is important; when it is `"true"` (note, this is the *string* `"true"`, not the *boolean* `true`), the document will not be built, except for when running `goo` with the `--draft` field. When it is `"false"` or not included, the document will be built.

Otherwise, documents support all regular markdown, inline and block LaTeX, code highlighting, :joy:-style emojis, and more; see the Goo documentation for more.
