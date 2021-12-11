#!/bin/bash
set -v -x
echo "::group::Debugging information:"
echo "workdir:"
pwd
echo "os info:"
uname -a
echo "Godot executable lib dependencies"
ldd /usr/bin/godot
echo "current workdir listing:"
ls -alh
echo "command line:"
echo "$@"
echo "::endgroup::"

echo "::group::Parsing and preparing variables"

targetDir=${GITHUB_WORKSPACE}
BASE_DIR=$1
DEBUG=$2
PACK=$3
PLATFORM_EXPORT=$4
PLATFORM="$5"
EXECNAME=$6
if [ "${BASE_DIR}x" != "x" ] && [ "$BASE_DIR" != "false" ]; then
    targetDir="${GITHUB_WORKSPACE}/${BASE_DIR}/"
    echo "Using this project directory: ${targetDir}"
fi
sanitizePlatform=$(echo "${PLATFORM}" | sed -e 's/[^A-Za-z0-9._-]/_/g')
localExportDirBase=.ci-exports/${sanitizePlatform}/
localTargetDirDebug=${localExportDirBase}/export-debug
localTargetDirPck=${localExportDirBase}/export-pck
localTargetDirPlatform=${localExportDirBase}/export-platform
targetDirDebug=${targetDir}/${localTargetDirDebug}/
targetDirPck=${targetDir}/${localTargetDirPck}/
targetDirPlatform=${targetDir}/${localTargetDirPlatform}/
projectFile=${targetDir}/project.godot
exportPresetFile=${targetDir}/export_presets.cfg
logfile="export-artifacts/engine-output-${sanitizePlatform}.log"

echo "::endgroup::"


echo "::group::Linking template directory to proper directory"
sharedir=~/.local/share/
mkdir -pv ${sharedir}
ln -sv /usr/share/godot ${sharedir}/godot
echo "::endgroup::"

echo "::group::Cleaning and preparing export directories..."
rm -Rfv "${targetDirDebug}" 2>&1 || true
mkdir -pv "${targetDirDebug}"
rm -Rfv "${targetDirPck}" 2>&1 || true
mkdir -pv "${targetDirPck}"
rm -Rfv "${targetDirPlatform}" 2>&1 || true
mkdir -pv "${targetDirPlatform}"
#rm -Rf ./export-artifacts 2>&1 || true
mkdir ./export-artifacts
echo "::endgroup::"

echo "::group::Evaluating input variables..."
sed "s[name=\"$PLATFORM\"[name=\"${sanitizePlatform}\"[g" -i "${exportPresetFile}" 
godot_args=("--no-window" "${projectFile}" "--quit")
ziping=""
zippostfix="$(date "+automated_build-%Y.%m.%d-%H%M%S")-$GITHUB_SHA"
if [ "${DEBUG}x" != "x" ] && [ "${DEBUG}x" != "falsex" ]; then
    godot_args+=("--export-debug" "${sanitizePlatform}" "${localTargetDirDebug}/${EXECNAME}")
    ziping="zip -0 -r -D \"export-artifacts/build-${sanitizePlatform}-export-with-debug-symbols-${zippostfix}.zip\" ${targetDirDebug} ;"
fi

if [ "${PACK}x" != "x" ] && [ "${PACK}x" != "falsex" ]; then
    godot_args+=("--export-pack" "${sanitizePlatform}" "${localTargetDirPck}/${EXECNAME}")
    ziping="${ziping}zip -0 -r -D \"export-artifacts/build-${sanitizePlatform}-export-pack-${zippostfix}.zip\" ${targetDirPck} ;"
fi

if [ "${PLATFORM_EXPORT}x" != "x" ] && [ "${PLATFORM_EXPORT}x" != "falsex" ]; then
    godot_args+=("--export" "${sanitizePlatform}" "${localTargetDirPlatform}/${EXECNAME}")
    ziping="${ziping}zip -0 -r -D \"export-artifacts/build-${sanitizePlatform}-export-${zippostfix}.zip\" ${targetDirPlatform} ;"
fi
echo "::endgroup::"

execs=(/usr/bin/godot)
chmod +x "${execs[0]}"
echo "::group::running the engine with following parameters: ${godot_args[*]}"
eval "${execs[0]}" ${godot_args[*]} > "${logfile}" 2>&1 
echo "::endgroup::"
echo "::group::ziping projects..."
eval "${ziping}" 2>&1 
echo "::endgroup::"
set +v +x
