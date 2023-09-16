#!/usr/bin/env bash

# from https://github.com/elixir-wallaby/wallaby/issues/468#issuecomment-810518368

install_path="/usr/local/bin/chromedriver"
chromedriver_path=$(command -v chromedriver)

function get_download_url {
 major_version=$1
 platform=$2
 curl -s curl "https://googlechromelabs.github.io/chrome-for-testing/latest-versions-per-milestone-with-downloads.json" \
    | jq -r '.milestones."'$major_version'".downloads.chromedriver | .[] | select(.platform | contains("'$platform'")) | .url'
}

function download_chromedriver {
  download_url=$1  
  platform=$2
  curl -s $download_url -o "chromedriver_${platform}.zip"
}

function install_chromedriver_executable {
  platform=$1
  unzip -oq "chromedriver_${platform}.zip"
  sudo mv "chromedriver-${platform}/chromedriver" ${install_path}
  rm "chromedriver_${platform}.zip"
  rm -rf "chromedriver-${platform}"
}

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     chrome_path="/usr/bin/google-chrome";;
    Darwin*)    chrome_path="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";;
esac
chromedriver_version=$("${chromedriver_path}" --version)
chrome_version=$("${chrome_path}" --version)

chromedriver_major_version=$("${chromedriver_path}" --version | cut -f 2 -d " " | cut -f 1 -d ".")
chrome_major_version=$("${chrome_path}" --version | cut -f 3 -d " " | cut -f 1 -d ".")

if [ "${chromedriver_major_version}" == "${chrome_major_version}" ]; then
  echo "Chromedriver matches chrome version ✓"
  exit 0
else
  echo "Wallaby often fails with 'invalid session id' if Chromedriver and Chrome have different versions."
  echo "Chromedriver version: ${chromedriver_major_version} (${chromedriver_version} at ${chromedriver_path})"
  echo "Chrome version      : ${chrome_major_version} (${chrome_version} at ${chrome_path})"

  echo ""
  echo "Install chromedriver version ${chrome_major_version}? [y/n]"
  read install
  echo "install = $install"

  if [[ "$install" == "y" ]]; then

    echo "What platform are you running? (eg: linux64, mac-arm64, mac-x64, win64...)"
    read platform

    # unfortunately rtx doesn't seem to know how to install recent version, so we download manually instead
    # rtx install chromedriver ${chrome_major_version}
    # rtx local chromedriver ${chrome_major_version}

    echo "determining latest chromedriver version ${chrome_major_version} for $platform ..."
    url=$(get_download_url $chrome_major_version $platform)
    echo "downloading ${url}..."
    $(download_chromedriver $url $platform)
    echo "installing chromedriver (requires sudo)..."
    $(install_chromedriver_executable $platform)
    echo "Done :)"
  else
    exit 1
  fi
fi