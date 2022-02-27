#!/bin/sh

help() {
  echo "usage: $0 COMMAND"
  echo "commands:"
  echo "	template"
  echo "	reset"
}

ask() {
  while test -z "$input"; do
    >&2 echo -n "$@: " && read input
  done

  echo "$input"
}

reset() {
  for file in *.backup; do
    mv "$file" "${file%.backup}"
  done
}

make_sed_script() {
  echo "s/{{${1}}}/${!1}/g"
}

template_file() {
  local var src_file

  var=$1

  #NAME DESCRIPTION KEYWORDS AUTHOR_NAME AUTHOR_EMAIL GITHUB_USER 

  sed_script="\
$(make_sed_script NAME);\
$(make_sed_script DESCRIPTION);\
$(make_sed_script KEYWORDS);\
$(make_sed_script AUTHOR_NAME);\
$(make_sed_script AUTHOR_EMAIL);\
$(make_sed_script GITHUB_USER)"

  test -n "$BACKUP" && suffix=".backup"
  sed -i$suffix "${sed_script}" $1
}

template_project() {
  if test -z "$BACKUP"; then
    echo -n "templating files without backup, continue? (YES/no) " && read confirm

    (test "${confirm,,}" != "yes" && test -n "$confirm") && exit 1
  fi

  test -f ~/.config/me && . ~/.config/me

  NAME=${NAME:-$(ask "Project name")}
  DESCRIPTION=${DESCRIPTION:-$(ask "Project description")}
  KEYWORDS=${KEYWORDS:-$(ask "Keywords (comma seperated)")}
  AUTHOR_NAME=${AUTHOR_EMAIL:-$(ask "Author name")}
  AUTHOR_EMAIL=${AUTHOR_EMAIL:-$(ask "Author email address")}
  GITHUB_USER=${GITHUB_USER:-$(ask "Author GitHub user")}

  for file in *; do
    test "$file" = "init.sh" && continue

    echo "templating $file"

    template_file "$file"
  done

  mkdir "$NAME"
  cp .templates/* "$NAME"/
}

case $1 in
  reset) reset ;;
  template) template_project ;;
  *) help && exit 1
esac
