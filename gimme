#!/usr/bin/env bash
# vim:noexpandtab:ts=2:sw=2:
#
#+  Usage: $(basename $0) [flags] [go-version] [version-prefix]
#+  -
#+  Version: ${GIMME_VERSION}
#+  Copyright: ${GIMME_COPYRIGHT}
#+  License URL: ${GIMME_LICENSE_URL}
#+  -
#+  Install go!  There are multiple types of installations available, with 'auto' being the default.
#+  If either 'auto' or 'binary' is specified as GIMME_TYPE, gimme will first check for an existing
#+  go installation.  This behavior may be disabled by providing '-f/--force/force' as first positional
#+  argument.
#+  -
#+  Option flags:
#+          -h --help help - show this help text and exit
#+    -V --version version - show the version only and exit
#+        -f --force force - remove the existing go installation if present prior to install
#+          -l --list list - list installed go versions and exit
#+        -k --known known - list known go versions and exit
#+  -
#+  Influential env vars:
#+  -
#+        GIMME_GO_VERSION - version to install (*REQUIRED*, may be given as first positional arg)
#+    GIMME_VERSION_PREFIX - prefix for installed versions (default '${GIMME_VERSION_PREFIX}',
#+                           may be given as second positional arg)
#+              GIMME_ARCH - arch to install (default '${GIMME_ARCH}')
#+        GIMME_BINARY_OSX - darwin-specific binary suffix (default '${GIMME_BINARY_OSX}')
#+        GIMME_ENV_PREFIX - prefix for env files (default '${GIMME_ENV_PREFIX}')
#+     GIMME_GO_GIT_REMOTE - git remote for git-based install (default '${GIMME_GO_GIT_REMOTE}')
#+                GIMME_OS - os to install (default '${GIMME_OS}')
#+               GIMME_TMP - temp directory (default '${GIMME_TMP}')
#+              GIMME_TYPE - install type to perform ('auto', 'binary', 'source', or 'git')
#+                           (default '${GIMME_TYPE}')
#+             GIMME_DEBUG - enable tracing if non-empty
#+      GIMME_NO_ENV_ALIAS - disable creation of env 'alias' file when os and arch match host
#+        GIMME_SILENT_ENV - omit the 'go version' line from env file
#+       GIMME_CGO_ENABLED - enable build of cgo support
#+     GIMME_CC_FOR_TARGET - cross compiler for cgo support
#+     GIMME_DOWNLOAD_BASE - override base URL dir for download (default '${GIMME_DOWNLOAD_BASE}')
#+        GIMME_LIST_KNOWN - override base URL for known go versions (default '${GIMME_LIST_KNOWN}')
#+  -
#
set -e
shopt -s nullglob
shopt -s dotglob
shopt -s extglob
set -o pipefail

[[ ${GIMME_DEBUG} ]] && set -x

GIMME_VERSION="v1.2.0"
GIMME_COPYRIGHT="Copyright (c) 2016 Dan Buch, Tianon Gravi, Travis CI GmbH"
GIMME_LICENSE_URL="https://raw.githubusercontent.com/travis-ci/gimme/v1.2.0/LICENSE"
export GIMME_VERSION
export GIMME_COPYRIGHT
export GIMME_LICENSE_URL

# _do_curl "url" "file"
_do_curl() {
	mkdir -p "$(dirname "${2}")"

	if command -v curl >/dev/null; then
		curl -sSLf "${1}" -o "${2}" 2>/dev/null
		return
	fi

	if command -v wget >/dev/null; then
		wget -q "${1}" -O "${2}" 2>/dev/null
		return
	fi

	if command -v fetch >/dev/null; then
		fetch -q "${1}" -o "${2}" 2>/dev/null
		return
	fi

	echo >&2 'error: no curl, wget, or fetch found'
	exit 1
}

# _do_curls "file" "url" ["url"...]
_do_curls() {
	f="${1}"
	shift
	[[ ! -s "${f}" ]] || return 0
	for url in "${@}"; do
		if _do_curl "${url}" "${f}"; then
			return
		fi
	done
	rm -f "${f}"
	return 1
}

# _binary "version" "file.tar.gz" "arch"
_binary() {
	local version=${1}
	local file=${2}
	local arch=${3}
	urls=(
		"${GIMME_DOWNLOAD_BASE}/go${version}.${GIMME_OS}-${arch}.tar.gz"
	)
	if [[ "${GIMME_OS}" == 'darwin' && "${GIMME_BINARY_OSX}" ]]; then
		urls=(
			"${GIMME_DOWNLOAD_BASE}/go${version}.${GIMME_OS}-${arch}-${GIMME_BINARY_OSX}.tar.gz"
			"${urls[@]}"
		)
	fi
	if [ "${arch}" = 'arm' ]; then
		# attempt "armv6l" vs just "arm" first (since that's what's officially published)
		urls=(
			"${GIMME_DOWNLOAD_BASE}/go${version}.${GIMME_OS}-${arch}v6l.tar.gz" # go1.6beta2 & go1.6rc1
			"${GIMME_DOWNLOAD_BASE}/go${version}.${GIMME_OS}-${arch}6.tar.gz" # go1.6beta1
			"${urls[@]}"
		)
	fi
	if [ "${GIMME_OS}" = 'windows' ]; then
		urls=(
			"${GIMME_DOWNLOAD_BASE}/go${version}.${GIMME_OS}-${arch}.zip"
		)
	fi
	_do_curls "${file}" "${urls[@]}"
}

# _source "version" "file.src.tar.gz"
_source() {
	urls=(
		"${GIMME_DOWNLOAD_BASE}/go${1}.src.tar.gz"
		"https://github.com/golang/go/archive/go${1}.tar.gz"
	)
	_do_curls "${2}" "${urls[@]}"
}

# _fetch "dir"
_fetch() {
	mkdir -p "$(dirname "${1}")"

	if [[ -d "${1}/.git" ]]; then
		(
			cd "${1}"
			git remote set-url origin "${GIMME_GO_GIT_REMOTE}"
			git fetch -q --all && git fetch -q --tags
		)
		return
	fi

	git clone -q "${GIMME_GO_GIT_REMOTE}" "${1}"
}

# _checkout "version" "dir"
_checkout() {
	_fetch "${2}"
	(cd "${2}" && {
		git reset -q --hard "origin/${1}" \
			|| git reset -q --hard "origin/go${1}" \
			|| { [ "${1}" = 'tip' ] && git reset -q --hard origin/master; } \
			|| git reset -q --hard "refs/tags/${1}" \
			|| git reset -q --hard "refs/tags/go${1}"
	} 2>/dev/null)
}

# _extract "file.tar.gz" "dir"
_extract() {
	mkdir -p "${2}"

	if [[ "${1}" == *.tar.gz ]]; then
		tar -xf "${1}" -C "${2}" --strip-components 1
	else
		unzip -q "${1}" -d "${2}"
		mv "${2}"/go/* "${2}"
		rmdir "${2}"/go
	fi
}

# _setup_bootstrap
_setup_bootstrap() {
	local versions=("1.9" "1.8" "1.7" "1.6" "1.5" "1.4")

	# try existing
	for v in "${versions[@]}"; do
		for candidate in "${GIMME_ENV_PREFIX}/go${v}"*".env"; do
			if [ -s "${candidate}" ]; then
				# shellcheck source=/dev/null
				GOROOT_BOOTSTRAP="$(source "${candidate}" 2>/dev/null && go env GOROOT)"
				export GOROOT_BOOTSTRAP
				return 0
			fi
		done
	done

	# try binary
	for v in "${versions[@]}"; do
		if [ -n "$(_try_binary "${v}" "${GIMME_HOSTARCH}")" ]; then
			export GOROOT_BOOTSTRAP="${GIMME_VERSION_PREFIX}/go${v}.${GIMME_OS}.${GIMME_HOSTARCH}"
			return 0
		fi
	done

	echo >&2 "Unable to setup go bootstrap from existing or binary"
	return 1
}

# _compile "dir"
_compile() {
	(
		if grep -q GOROOT_BOOTSTRAP "${1}/src/make.bash" &>/dev/null; then
			_setup_bootstrap || return 1
		fi
		cd "${1}"
		if [[ -d .git ]]; then
			git clean -dfx -q
		fi
		cd src
		export GOOS="${GIMME_OS}" GOARCH="${GIMME_ARCH}"
		export CGO_ENABLED="${GIMME_CGO_ENABLED}"
		export CC_FOR_TARGET="${GIMME_CC_FOR_TARGET}"

		local make_log="${1}/make.${GOOS}.${GOARCH}.log"
		if [[ "${GIMME_DEBUG}" -gt "1" ]]; then
			./make.bash 2>&1 | tee "${make_log}" 1>&2 || return 1
		else
			./make.bash &>"${make_log}" || return 1
		fi
	)
}

_can_compile() {
	cat >"${GIMME_TMP}/test.go" <<'EOF'
package main
import "os"
func main() {
	os.Exit(0)
}
EOF
	"${1}/bin/go" run "${GIMME_TMP}/test.go"
}

# _env "dir"
_env() {
	[[ -d "${1}/bin" && -x "${1}/bin/go" ]] || return 1

	# if we try to run a Darwin binary on Linux, we need to fail so 'auto' can fallback to cross-compiling from source
	# automatically
	GOROOT="${1}" "${1}/bin/go" version &>/dev/null || return 1

	# https://twitter.com/davecheney/status/431581286918934528
	# we have to GOROOT sometimes because we use official release binaries in unofficial locations :(
	#
	# Issue 87 leads to:
	#   No, we should _always_ set GOROOT when using official release binaries, and sanest to just always set it.
	#   The "avoid setting it" is _only_ for people using official releases in official locations.
	#   Tools like `gimme` are the reason that GOROOT-in-env exists.

	echo
	if [[ "$(GOROOT="${1}" "${1}/bin/go" env GOHOSTOS)" == "${GIMME_OS}" ]]; then
		echo 'unset GOOS;'
	else
		echo 'export GOOS="'"${GIMME_OS}"'";'
	fi
	if [[ "$(GOROOT="${1}" "${1}/bin/go" env GOHOSTARCH)" == "${GIMME_ARCH}" ]]; then
		echo 'unset GOARCH;'
	else
		echo 'export GOARCH="'"${GIMME_ARCH}"'";'
	fi

	echo "export GOROOT='${1}';"

	# shellcheck disable=SC2016
	echo 'export PATH="'"${1}/bin"':${PATH}";'
	if [[ -z "${GIMME_SILENT_ENV}" ]]; then
		echo 'go version >&2;'
	fi
	echo
}

# _env_alias "dir" "env-file"
_env_alias() {
	if [[ "${GIMME_NO_ENV_ALIAS}" ]]; then
		echo "${2}"
		return
	fi

	if [[ "$(GOROOT="${1}" "${1}/bin/go" env GOHOSTOS)" == "${GIMME_OS}" && "$(GOROOT="${1}" "${1}/bin/go" env GOHOSTARCH)" == "${GIMME_ARCH}" ]]; then
		local dest="${GIMME_ENV_PREFIX}/go${GIMME_GO_VERSION}.env"
		cp "${2}" "${dest}"
		ln -sf "${dest}" "${GIMME_ENV_PREFIX}/latest.env"
		echo "${dest}"
	else
		echo "${2}"
	fi
}

_try_existing() {
	case "${1}" in
		binary)
			local existing_ver="${GIMME_VERSION_PREFIX}/go${GIMME_GO_VERSION}.${GIMME_OS}.${GIMME_ARCH}"
			local existing_env="${GIMME_ENV_PREFIX}/go${GIMME_GO_VERSION}.${GIMME_OS}.${GIMME_ARCH}.env"
			;;
		source)
			local existing_ver="${GIMME_VERSION_PREFIX}/go${GIMME_GO_VERSION}.src"
			local existing_env="${GIMME_ENV_PREFIX}/go${GIMME_GO_VERSION}.src.env"
			;;
		*)
			_try_existing binary || _try_existing source
			return $?
			;;
	esac

	if [[ -x "${existing_ver}/bin/go" && -s "${existing_env}" ]]; then
		# newer envs have existing semi-colon at end of line, because newer gimme
		# puts them there; envs created before that change lack those semi-colons
		# and should gain them, to make it easier for people using eval without
		# double-quoting the command substition.
		sed -e 's/\([^;]\)$/\1;/' <"${existing_env}"
		# gimme is the corner-case where GOROOT _should_ be overriden, since if the
		# ancilliary tooling's system-internal DefaultGoroot exists, and GOROOT is
		# unset, then it will be used and the wrong golang will be picked up.
		# Lots of old installs won't have GOROOT; munge it from $PATH
		if grep -qs '^unset GOROOT' -- "${existing_env}"; then
			sed -n -e 's/^export PATH="\(.*\)\/bin:.*$/export GOROOT='"'"'\1'"'"';/p' <"${existing_env}"
			echo
		fi
		return
	fi

	return 1
}

# _try_binary "version" "arch"
_try_binary() {
	local version=${1}
	local arch=${2}
	local bin_tgz="${GIMME_TMP}/go${version}.${GIMME_OS}.${arch}.tar.gz"
	local bin_dir="${GIMME_VERSION_PREFIX}/go${version}.${GIMME_OS}.${arch}"
	local bin_env="${GIMME_ENV_PREFIX}/go${version}.${GIMME_OS}.${arch}.env"

	if [ "${GIMME_OS}" = 'windows' ]; then
		bin_tgz=${bin_tgz%.tar.gz}.zip
	fi

	_binary "${version}" "${bin_tgz}" "${arch}" || return 1
	_extract "${bin_tgz}" "${bin_dir}" || return 1
	_env "${bin_dir}" | tee "${bin_env}" || return 1
	echo "export GIMME_ENV=\"$(_env_alias "${bin_dir}" "${bin_env}")\""
}

_try_source() {
	local src_tgz="${GIMME_TMP}/go${GIMME_GO_VERSION}.src.tar.gz"
	local src_dir="${GIMME_VERSION_PREFIX}/go${GIMME_GO_VERSION}.src"
	local src_env="${GIMME_ENV_PREFIX}/go${GIMME_GO_VERSION}.src.env"

	_source "${GIMME_GO_VERSION}" "${src_tgz}" || return 1
	_extract "${src_tgz}" "${src_dir}" || return 1
	_compile "${src_dir}" || return 1
	_env "${src_dir}" | tee "${src_env}" || return 1
	echo "export GIMME_ENV=\"$(_env_alias "${src_dir}" "${src_env}")\""
}

_try_git() {
	local git_dir="${GIMME_VERSION_PREFIX}/go"
	local git_env="${GIMME_ENV_PREFIX}/go.git.${GIMME_OS}.${GIMME_ARCH}.env"

	_checkout "${GIMME_GO_VERSION}" "${git_dir}" || return 1
	_compile "${git_dir}" || return 1
	_env "${git_dir}" | tee "${git_env}" || return 1
	echo "export GIMME_ENV=\"$(_env_alias "${git_dir}" "${git_env}")\""
}

_wipe_version() {
	local env_file="${GIMME_ENV_PREFIX}/go${1}.${GIMME_OS}.${GIMME_ARCH}.env"

	if [[ -s "${env_file}" ]]; then
		rm -rf "$(awk -F\" '/GOROOT/ { print $2 }' "${env_file}")"
		rm -f "${env_file}"
	fi
}

_list_versions() {
	if [ ! -d "${GIMME_VERSION_PREFIX}" ]; then
		return 0
	fi

	local current_version
	current_version="$(go env GOROOT 2>/dev/null)"
	current_version="${current_version##*/go}"
	current_version="${current_version%%.${GIMME_OS}.*}"

	for d in "${GIMME_VERSION_PREFIX}/go"*".${GIMME_OS}."*; do
		local cleaned="${d##*/go}"
		cleaned="${cleaned%%.${GIMME_OS}.*}"
		echo -en "${cleaned}"
		if [[ "${cleaned}" == "${current_version}" ]]; then
			echo -en ' <= current' >&2
		fi
		echo
	done
}

_list_known() {
	local exp="go([[:alnum:]\.]*)\.src.*" # :alnum: catches beta versions too
	local list="${GIMME_TMP}/known-versions"

	local known
	known="$(_list_versions 2>/dev/null)"

	_do_curl "${GIMME_LIST_KNOWN}" "${list}"

	while read -r line; do
		if [[ "${line}" =~ ${exp} ]]; then
			known="$known\n${BASH_REMATCH[1]}"
		fi
	done <"${list}"

	rm -f "${list}" &>/dev/null
	echo -e "${known}" | grep . | sort -n -r | uniq
}

_realpath() {
	# shellcheck disable=SC2005
	[ -d "$1" ] && echo "$(cd "$1" && pwd)" || echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

_get_curr_stable() {
	local stable="${GIMME_VERSION_PREFIX}/stable"
	local now_secs
	now_secs="$(date +%s)"
	local stable_age
	stable_age="$(_stat_unix "${stable}" 2>/dev/null || echo 0)"
	local age
	age=$((now_secs - stable_age))

	if [[ "${age}" -gt 86400 ]]; then
		_update_stable "${stable}"
	fi

	cat "${stable}"
}

_update_stable() {
	local stable="${1}"
	local exp="go([[:digit:]\.]*)\.src.*"
	local tmp_versions="${GIMME_TMP}/versions"
	local url="https://www.googleapis.com/storage/v1/b/golang/o?fields=items%2Fname&maxResults=999999"
	local vers=""

	mkdir -p "$(dirname "${stable}")"

	_do_curl "${url}" "${tmp_versions}"

	while read -r line; do
		if [[ "${line}" =~ ${exp} ]]; then
			vers="$vers\n${BASH_REMATCH[1]}"
		fi
	done <"${tmp_versions}"

	rm -f "${tmp_versions}" &>/dev/null
	echo -e "${vers}" | sort -n -r | head -n1 >"${stable}"
}

_stat_unix() {
	local filename="${1}"
	case "${GIMME_HOSTOS}" in
		darwin | *bsd)
			stat -f %a "${filename}"
			;;
		linux)
			stat -c %Y "${filename}"
			;;
	esac
}

_assert_version_given() {
	# By the time we're called, aliases such as "stable" must have been resolved
	# but we could be a reference in git.
	#
	# Versions can include suffices such as in "1.8beta2", so our assumption is that
	# there will always be a minor present; the first public release was "1.0" so
	# we assume "2.0" not "2".

	if [[ -z "${GIMME_GO_VERSION}" ]]; then
		echo >&2 'error: no GIMME_GO_VERSION supplied'
		echo >&2 "  ex: GIMME_GO_VERSION=1.4.1 ${0} ${*}"
		echo >&2 "  ex: ${0} 1.4.1 ${*}"
		exit 1
	fi

	if [[ "${GIMME_GO_VERSION}" == +([[:digit:]]).+([[:digit:]])* ]]; then
		return 0
	fi

	if [[ "${GIMME_TYPE}" == "auto" || "${GIMME_TYPE}" == "git" ]]; then
		local git_dir="${GIMME_VERSION_PREFIX}/go"
		_checkout "${GIMME_GO_VERSION}" "${git_dir}" && return 0
	fi

	echo >&2 'error: GIMME_GO_VERSION not recognized as valid'
	echo >&2 "  got: ${GIMME_GO_VERSION}"
	exit 1
}

_exclude_from_backups() {
	# Please avoid anything which requires elevated privileges or is obnoxious
	# enough to offend the invoker
	case "${GIMME_HOSTOS}" in
		darwin)
			# Darwin: Time Machine is "standard", we can add others.  The default
			# mechanism is sticky, as an attribute on the dir, requires no
			# privileges, is idempotent (and doesn't support -- to end flags).
			tmutil addexclusion "$@"
			;;
	esac
}

_versint() {
	local args=(${1//[^0-9]/ })
	printf '1%03d%03d%03d%03d' "${args[@]}"
}

_to_goarch() {
	case "${1}" in
		aarch64) echo "arm64" ;;
		*) echo "${1}" ;;
	esac
}

: "${GIMME_OS:=$(uname -s | tr '[:upper:]' '[:lower:]')}"
: "${GIMME_HOSTOS:=$(uname -s | tr '[:upper:]' '[:lower:]')}"
: "${GIMME_ARCH:=$(_to_goarch "$(uname -m)")}"
: "${GIMME_HOSTARCH:=$(_to_goarch "$(uname -m)")}"
: "${GIMME_ENV_PREFIX:=${HOME}/.gimme/envs}"
: "${GIMME_VERSION_PREFIX:=${HOME}/.gimme/versions}"
: "${GIMME_TMP:=${TMPDIR:-/tmp}/gimme}"
: "${GIMME_GO_GIT_REMOTE:=https://github.com/golang/go.git}"
: "${GIMME_TYPE:=auto}" # 'auto', 'binary', 'source', or 'git'
: "${GIMME_BINARY_OSX:=osx10.8}"
: "${GIMME_DOWNLOAD_BASE:=https://storage.googleapis.com/golang}"
: "${GIMME_LIST_KNOWN:=https://golang.org/dl}"

# The version prefix must be an absolute path
case "${GIMME_VERSION_PREFIX}" in
	/*) true ;;
	*)
		echo >&2 " Fixing GIMME_VERSION_PREFIX from relative: $GIMME_VERSION_PREFIX"
		GIMME_VERSION_PREFIX="$(pwd)/${GIMME_VERSION_PREFIX}"
		echo >&2 " to: $GIMME_VERSION_PREFIX"
		;;
esac

if [[ "${GIMME_OS}" == mingw* ]]; then
	# Minimalist GNU for Windows
	GIMME_OS='windows'

	if [ "${GIMME_ARCH}" = 'i686' ]; then
		GIMME_ARCH="386"
	else
		GIMME_ARCH="amd64"
	fi
fi

while [[ $# -gt 0 ]]; do
	case "${1}" in
		-h | --help | help | wat)
			_old_ifs="$IFS"
			IFS=';'
			awk '/^#\+  / {
				sub(/^#\+  /, "", $0) ;
				sub(/-$/, "", $0) ;
				print $0
			}' "$0" | while read -r line; do
				eval "echo \"$line\""
			done
			IFS="$_old_ifs"
			exit 0
			;;
		-V | --version | version)
			echo "${GIMME_VERSION}"
			exit 0
			;;
		-l | --list | list)
			_list_versions
			exit 0
			;;
		-k | --known | known)
			_list_known
			exit 0
			;;
		-f | --force | force)
			force=1
			;;
		-i | install)
			true # ignore a dummy argument
			;;
		*)
			break
			;;
	esac
	shift
done

if [[ -n "${1}" ]]; then
	GIMME_GO_VERSION="${1}"
fi
if [[ -n "${2}" ]]; then
	GIMME_VERSION_PREFIX="${2}"
fi

case "${GIMME_ARCH}" in
	x86_64) GIMME_ARCH=amd64 ;;
	x86) GIMME_ARCH=386 ;;
	arm64)
		if [[ "${GIMME_GO_VERSION}" != master && "$(_versint "${GIMME_GO_VERSION}")" < "$(_versint 1.5)" ]]; then
			echo >&2 "error: ${GIMME_ARCH} is not supported by this go version"
			echo >&2 "try go1.5 or newer"
			exit 1
		fi
		if [[ "${GIMME_HOSTOS}" == "linux" && "${GIMME_HOSTARCH}" != "${GIMME_ARCH}" ]]; then
			: "${GIMME_CC_FOR_TARGET:="aarch64-linux-gnu-gcc"}"
		fi
		;;
	arm*) GIMME_ARCH=arm ;;
esac

case "${GIMME_HOSTARCH}" in
	x86_64) GIMME_HOSTARCH=amd64 ;;
	x86) GIMME_HOSTARCH=386 ;;
	arm64) ;;
	arm*) GIMME_HOSTARCH=arm ;;
esac

if [[ "${GIMME_GO_VERSION}" == "stable" ]]; then
	GIMME_GO_VERSION=$(_get_curr_stable)
fi

_assert_version_given "$@"

[ ${force} ] && _wipe_version "${GIMME_GO_VERSION}"

unset GOARCH
unset GOBIN
unset GOOS
unset GOPATH
unset GOROOT
unset CGO_ENABLED
unset CC_FOR_TARGET

mkdir -p "${GIMME_VERSION_PREFIX}" "${GIMME_ENV_PREFIX}"
# The envs dir stays small and provides a record of what had been installed
# whereas the versions dir grows by hundreds of MB per version and is not
# intended to support local modifications (as that subverts the point of gimme)
# _and_ is a cache, so we're unilaterally declaring that the contents of
# the versions dir should be excluded from system backups.
_exclude_from_backups "${GIMME_VERSION_PREFIX}"

GIMME_VERSION_PREFIX="$(_realpath "${GIMME_VERSION_PREFIX}")"
GIMME_ENV_PREFIX="$(_realpath "${GIMME_ENV_PREFIX}")"

if ! case "${GIMME_TYPE}" in
	binary) _try_existing binary || _try_binary "${GIMME_GO_VERSION}" "${GIMME_ARCH}" ;;
	source) _try_existing source || _try_source || _try_git ;;
	git) _try_git ;;
	auto) _try_existing || _try_binary "${GIMME_GO_VERSION}" "${GIMME_ARCH}" || _try_source || _try_git ;;
	*)
		echo >&2 "I don't know how to '${GIMME_TYPE}'."
		echo >&2 "  Try 'auto', 'binary', 'source', or 'git'."
		exit 1
		;;
esac; then
	echo >&2 "I don't have any idea what to do with '${GIMME_GO_VERSION}'."
	echo >&2 "  (using type '${GIMME_TYPE}')"
	exit 1
fi
