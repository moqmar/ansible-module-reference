#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -eu
IFS=$'\n'

rm -rf source docs
mkdir -p source docs
toc=""

for module in `
  curl -s "https://docs.ansible.com/ansible/latest/modules/modules_by_category.html" |
  grep -F '<li class="toctree-l4"><a class="reference internal" href="list_of_' |
  grep -Fv 'list_of_all_modules.html' |
  sed -e 's@^.*href="@@g' -e 's@ modules<.*$@@g' -e 's@">@\t@g'`
do
  module_link=`echo "$module" | awk -F '\t' '{ print $1 }'`
  module_name=`echo "$module" | awk -F '\t' '{ print $2 }'`
  module_slug=`echo "$module_name" | sed 's@ @-@g' | tr '[:upper:]' '[:lower:]'`
  echo "$module_name"
  
  toc="$toc<a class='module-group'>$module_name</a>\n"
  for module in `
    curl -s "https://docs.ansible.com/ansible/latest/modules/$module_link" |
    grep -E '<li><a class="reference internal" href="|<h2>' |
    sed -e 's@^.*<h2>@@g' -e 's@<.*</h2>.*$@@g' -e 's@^.*href="@@g' -e 's@#.*std-ref">@\t@g' -e 's@<.*$@@g' -e 's@ - @\t@g'`
  do
    module_link=`echo "$module" | awk -F '\t' '{ print $1 }'`
    module_name=`echo "$module" | awk -F '\t' '{ print $2 }'`
    module_desc=`echo "$module" | awk -F '\t' '{ print $3 }'`
    if [ -z "$module_name" ]; then
      echo "  $module_link"
      toc="$toc<a class='module-header'>$module_link</a>\n"
    else
      echo "    $module_name"
      toc="$toc<a class='module' href='$module_name.html'>$module_name <small>$module_desc</small></a>\n"
      curl -s "https://docs.ansible.com/ansible/latest/modules/$module_link" |
        grep '^<span id="'`echo "$module_name" | sed s._.-.g`'-module' -A 10000 |
        sed -E -e ':a;N;$!ba;s/\n<span id="(.*|\n)*//g' -e ':a;N;$!ba;s/<\/div>(\s|\n)*<\/div>(\s|\n)*<div id="search-results">(.*|\n)*//g' > "source/$module_name.html"
    fi
  done
done

echo > source/index.html

for f in `ls -1 source`; do
  cat template/top.html | sed "s/__MODULE_NAME__/$(echo $f | sed 's/\.html//')/g" > "docs/$f"
  echo "$toc" | sed 's/\\n/\n/g' >> "docs/$f"
  cat template/middle.html >> "docs/$f"
  cat "source/$f" >> "docs/$f"
  cat template/bottom.html >> "docs/$f"
done

cp template/{script.js,style.css} docs