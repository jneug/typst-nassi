root := justfile_directory()
package-fork := "$TYPST_PKG_FORK"

export TYPST_ROOT := root

[private]
default:
  @just --list --unsorted

# generate manual
doc:
  typst compile docs/manual.typ docs/manual.pdf
  typst compile docs/thumbnail.typ thumbnail-light.svg
  typst compile --input theme=dark docs/thumbnail.typ thumbnail-dark.svg

# run test suite
test *args:
  tt run --use-system-fonts {{ args }}

# update test cases
update *args:
  tt update --use-system-fonts {{ args }}

# package the library into the specified destination folder
package target:
  ./scripts/package "{{target}}"

# install the library with the "@local" prefix
install: (package "@local")

# install the library with the "@preview" prefix (for pre-release testing)
install-preview: (package "@preview")

prepare: (package package-fork)

# create a symbolic link to this library in the target repository
link target="@local":
  ./scripts/link "{{target}}"

link-preview: (link "@preview")

[private]
remove target:
  ./scripts/uninstall "{{target}}"

# uninstalls the library from the "@local" prefix
uninstall: (remove "@local")

# uninstalls the library from the "@preview" prefix (for pre-release testing)
uninstall-preview: (remove "@preview")

# unlinks the library from the "@local" prefix
unlink: (remove "@local")

# unlinks the library from the "@preview" prefix
unlink-preview: (remove "@preview")

# run ci suite
ci: test doc


assets:
  typst c --root . -f png assets/example-1.typ
  typst c --root . -f png assets/example-2.typ
  typst c --root . -f png assets/example-3.typ
  typst c --root . -f png assets/example-cetz.typ
  typst c --root . -f png assets/example-cetz-2.typ
