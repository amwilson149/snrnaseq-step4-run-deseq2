
# 01. Set up environment
# 01a. Activate conda environment
ml anaconda3/2020.11
module  load 'anaconda3/2020.11'
Shell debugging temporarily silenced: export LMOD_SH_DBG_ON=1 for Lmod's output

The following have been reloaded with a version change:
  1) gcc/14.2.0 => gcc/8.3.0

Shell debugging restarted
ml -python
module  load '-python'
Shell debugging temporarily silenced: export LMOD_SH_DBG_ON=1 for Lmod's output
Shell debugging restarted
source /hpc/packages/minerva-centos7/anaconda3/2020.11/etc/profile.d/conda.sh
export CONDA_EXE='/hpc/packages/minerva-centos7/anaconda3/2020.11/bin/conda'
export _CE_M=''
export _CE_CONDA=''
export CONDA_PYTHON_EXE='/hpc/packages/minerva-centos7/anaconda3/2020.11/bin/python'

# Copyright (C) 2012 Anaconda, Inc
# SPDX-License-Identifier: BSD-3-Clause

__add_sys_prefix_to_path() {
    # In dev-mode CONDA_EXE is python.exe and on Windows
    # it is in a different relative location to condabin.
    if [ -n "${_CE_CONDA}" ] && [ -n "${WINDIR+x}" ]; then
        SYSP=$(\dirname "${CONDA_EXE}")
    else
        SYSP=$(\dirname "${CONDA_EXE}")
        SYSP=$(\dirname "${SYSP}")
    fi

    if [ -n "${WINDIR+x}" ]; then
        PATH="${SYSP}/bin:${PATH}"
        PATH="${SYSP}/Scripts:${PATH}"
        PATH="${SYSP}/Library/bin:${PATH}"
        PATH="${SYSP}/Library/usr/bin:${PATH}"
        PATH="${SYSP}/Library/mingw-w64/bin:${PATH}"
        PATH="${SYSP}:${PATH}"
    else
        PATH="${SYSP}/bin:${PATH}"
    fi
    \export PATH
}

__conda_hashr() {
    if [ -n "${ZSH_VERSION:+x}" ]; then
        \rehash
    elif [ -n "${POSH_VERSION:+x}" ]; then
        :  # pass
    else
        \hash -r
    fi
}

__conda_activate() {
    if [ -n "${CONDA_PS1_BACKUP:+x}" ]; then
        # Handle transition from shell activated with conda <= 4.3 to a subsequent activation
        # after conda updated to >= 4.4. See issue #6173.
        PS1="$CONDA_PS1_BACKUP"
        \unset CONDA_PS1_BACKUP
    fi

    \local cmd="$1"
    shift
    \local ask_conda
    CONDA_INTERNAL_OLDPATH="${PATH}"
    __add_sys_prefix_to_path
    ask_conda="$(PS1="$PS1" "$CONDA_EXE" $_CE_M $_CE_CONDA shell.posix "$cmd" "$@")" || \return $?
    rc=$?
    PATH="${CONDA_INTERNAL_OLDPATH}"
    \eval "$ask_conda"
    if [ $rc != 0 ]; then
        \export PATH
    fi
    __conda_hashr
}

__conda_reactivate() {
    \local ask_conda
    CONDA_INTERNAL_OLDPATH="${PATH}"
    __add_sys_prefix_to_path
    ask_conda="$(PS1="$PS1" "$CONDA_EXE" $_CE_M $_CE_CONDA shell.posix reactivate)" || \return $?
    PATH="${CONDA_INTERNAL_OLDPATH}"
    \eval "$ask_conda"
    __conda_hashr
}

conda() {
    if [ "$#" -lt 1 ]; then
        "$CONDA_EXE" $_CE_M $_CE_CONDA
    else
        \local cmd="$1"
        shift
        case "$cmd" in
            activate|deactivate)
                __conda_activate "$cmd" "$@"
                ;;
            install|update|upgrade|remove|uninstall)
                CONDA_INTERNAL_OLDPATH="${PATH}"
                __add_sys_prefix_to_path
                "$CONDA_EXE" $_CE_M $_CE_CONDA "$cmd" "$@"
                \local t1=$?
                PATH="${CONDA_INTERNAL_OLDPATH}"
                if [ $t1 = 0 ]; then
                    __conda_reactivate
                else
                    return $t1
                fi
                ;;
            *)
                CONDA_INTERNAL_OLDPATH="${PATH}"
                __add_sys_prefix_to_path
                "$CONDA_EXE" $_CE_M $_CE_CONDA "$cmd" "$@"
                \local t1=$?
                PATH="${CONDA_INTERNAL_OLDPATH}"
                return $t1
                ;;
        esac
    fi
}

if [ -z "${CONDA_SHLVL+x}" ]; then
    \export CONDA_SHLVL=0
    # In dev-mode CONDA_EXE is python.exe and on Windows
    # it is in a different relative location to condabin.
    if [ -n "${_CE_CONDA+x}" ] && [ -n "${WINDIR+x}" ]; then
        PATH="$(\dirname "$CONDA_EXE")/condabin${PATH:+":${PATH}"}"
    else
        PATH="$(\dirname "$(\dirname "$CONDA_EXE")")/condabin${PATH:+":${PATH}"}"
    fi
    \export PATH

    # We're not allowing PS1 to be unbound. It must at least be set.
    # However, we're not exporting it, which can cause problems when starting a second shell
    # via a first shell (i.e. starting zsh from bash).
    if [ -z "${PS1+x}" ]; then
        PS1=
    fi
fi
conda activate diffexpr
PS1='(diffexpr) '
export PATH='/hpc/users/wilsoa28/.conda/envs/diffexpr/bin:/hpc/packages/minerva-centos7/anaconda3/2020.11/bin:/hpc/packages/minerva-centos7/gcc/8.3.0_32b/bin:/hpc/packages/minerva-centos7/anaconda3/2020.11/condabin:/hpc/users/wilsoa28/google-cloud-sdk/bin:/hpc/users/wilsoa28/git-filter-repo:/hpc/packages/minerva-rocky9/git/2.46.0/bin:/hpc/packages/minerva-common/vim/8.0/bin:/hpc/lsf/10.1/linux3.10-glibc2.17-x86_64/etc:/hpc/lsf/10.1/linux3.10-glibc2.17-x86_64/bin:/bin:/usr/bin:/usr/mbin:/local/bin:/usr/local:/usr/ucb:/usr/local/sbin:/usr/sbin:/usr/lpp/mmfs/bin:/hpc/users/wilsoa28/.local/bin:/hpc/users/wilsoa28/bin'
export CONDA_PREFIX='/hpc/users/wilsoa28/.conda/envs/diffexpr'
export CONDA_SHLVL='1'
export CONDA_DEFAULT_ENV='diffexpr'
export CONDA_PROMPT_MODIFIER='(diffexpr) '
export CONDA_EXE='/hpc/packages/minerva-centos7/anaconda3/2020.11/bin/conda'
export _CE_M=''
export _CE_CONDA=''
export CONDA_PYTHON_EXE='/hpc/packages/minerva-centos7/anaconda3/2020.11/bin/python'
. "/hpc/users/wilsoa28/.conda/envs/diffexpr/etc/conda/activate.d/activate-binutils_linux-64.sh"
# shellcheck shell=sh

# This function takes no arguments
# It tries to determine the name of this file in a programatic way.
_get_sourced_filename() {
    # shellcheck disable=SC3054,SC2296 # non-POSIX array access and bad '(' are guarded
    if [ -n "${BASH_SOURCE+x}" ] && [ -n "${BASH_SOURCE[0]}" ]; then
        # shellcheck disable=SC3054 # non-POSIX array access is guarded
        basename "${BASH_SOURCE[0]}"
    elif [ -n "$ZSH_NAME" ] && [ -n "${(%):-%x}" ]; then
        # in zsh use prompt-style expansion to introspect the same information
        # see http://stackoverflow.com/questions/9901210/bash-source0-equivalent-in-zsh
        # shellcheck disable=SC2296  # bad '(' is guarded
        basename "${(%):-%x}"
    else
        echo "UNKNOWN FILE"
    fi
}

# The arguments to this are:
# 1. activation nature {activate|deactivate}
# 2. toolchain nature {build|host|ccc}
# 3. machine (should match -dumpmachine)
# 4. prefix (including any final -)
# 5+ program (or environment var comma value)
# The format for 5+ is name{,,value}. If value is specified
#  then name taken to be an environment variable, otherwise
#  it is taken to be a program. In this case, which is used
#  to find the full filename during activation. The original
#  value is stored in environment variable CONDA_BACKUP_NAME
#  For deactivation, the distinction is irrelevant as in all
#  cases NAME simply gets reset to CONDA_BACKUP_NAME.  It is
#  a fatal error if a program is identified but not present.
_tc_activation() {
  local act_nature="$1"; shift
  local tc_prefix="$1"; shift
  local thing
  local newval
  local from
  local to
  local pass

  if [ "${act_nature}" = "activate" ]; then
    from=""
    to="CONDA_BACKUP_"
  else
    from="CONDA_BACKUP_"
    to=""
  fi

  for pass in check apply; do
    for thing in "$@"; do
      case "${thing}" in
        *,*)
          newval=$(echo "${thing}" | sed "s,^[^\,]*\,\(.*\),\1,")
          thing=$(echo "${thing}" | sed "s,^\([^\,]*\)\,.*,\1,")
          ;;
        *)
          newval="${CONDA_PREFIX}/bin/${tc_prefix}${thing}"
          if [ ! -x "${newval}" ] && [ "${pass}" = "check" ]; then
            echo "ERROR: This cross-compiler package contains no program ${newval}"
            return 1
          fi
          ;;
      esac
      if [ "${pass}" = "apply" ]; then
        thing=$(echo "${thing}" | tr 'a-z+-.' 'A-ZX__')
        eval oldval="\$${from}$thing"
        if [ -n "${oldval}" ]; then
          eval export "${to}'${thing}'=\"${oldval}\""
        else
          eval unset '${to}${thing}'
        fi
        if [ -n "${newval}" ]; then
          eval export "'${from}${thing}=${newval}'"
        else
          eval unset '${from}${thing}'
        fi
      fi
    done
  done
  return 0
}

if [ "${CONDA_BUILD:-0}" = "1" ]; then
  if [ -f /tmp/old-env-$$.txt ]; then
    rm -f /tmp/old-env-$$.txt || true
  fi
  env > /tmp/old-env-$$.txt
fi

# gold has not been (cannot be?) built for powerpc
if echo x86_64-conda-linux-gnu | grep powerpc > /dev/null; then
  GOLD_USED=
else
  GOLD_USED=ld.gold
fi

_tc_activation \
  activate x86_64-conda-linux-gnu- \
  addr2line ar as c++filt elfedit gprof ld ${GOLD_USED} nm objcopy objdump ranlib readelf size strings strip \

oldval=$ADDR2LINE
unset ${to}${thing}
export 'ADDR2LINE=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-addr2line'
oldval=$AR
unset ${to}${thing}
export 'AR=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-ar'
oldval=$AS
unset ${to}${thing}
export 'AS=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-as'
oldval=$CXXFILT
unset ${to}${thing}
export 'CXXFILT=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-c++filt'
oldval=$ELFEDIT
unset ${to}${thing}
export 'ELFEDIT=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-elfedit'
oldval=$GPROF
unset ${to}${thing}
export 'GPROF=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-gprof'
oldval=$LD
unset ${to}${thing}
export 'LD=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-ld'
oldval=$LD_GOLD
unset ${to}${thing}
export 'LD_GOLD=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-ld.gold'
oldval=$NM
unset ${to}${thing}
export 'NM=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-nm'
oldval=$OBJCOPY
unset ${to}${thing}
export 'OBJCOPY=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-objcopy'
oldval=$OBJDUMP
unset ${to}${thing}
export 'OBJDUMP=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-objdump'
oldval=$RANLIB
unset ${to}${thing}
export 'RANLIB=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-ranlib'
oldval=$READELF
unset ${to}${thing}
export 'READELF=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-readelf'
oldval=$SIZE
unset ${to}${thing}
export 'SIZE=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-size'
oldval=$STRINGS
unset ${to}${thing}
export 'STRINGS=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-strings'
oldval=$STRIP
unset ${to}${thing}
export 'STRIP=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-strip'
if [ $? -ne 0 ]; then
  echo "ERROR: $(_get_sourced_filename) failed, see above for details"
#exit 1
else
  if [ "${CONDA_BUILD:-0}" = "1" ]; then
    if [ -f /tmp/new-env-$$.txt ]; then
      rm -f /tmp/new-env-$$.txt || true
    fi
    env > /tmp/new-env-$$.txt

    echo "INFO: $(_get_sourced_filename) made the following environmental changes:"
    diff -U 0 -rN /tmp/old-env-$$.txt /tmp/new-env-$$.txt | tail -n +4 | grep "^-.*\|^+.*" | grep -v "CONDA_BACKUP_" | sort
    rm -f /tmp/old-env-$$.txt /tmp/new-env-$$.txt || true
  fi
fi
. "/hpc/users/wilsoa28/.conda/envs/diffexpr/etc/conda/activate.d/activate-gcc_linux-64.sh"
# shellcheck shell=sh

# This function takes no arguments
# It tries to determine the name of this file in a programatic way.
_get_sourced_filename() {
    # shellcheck disable=SC3054,SC2296 # non-POSIX array access and bad '(' are guarded
    if [ -n "${BASH_SOURCE+x}" ] && [ -n "${BASH_SOURCE[0]}" ]; then
        # shellcheck disable=SC3054 # non-POSIX array access is guarded
        basename "${BASH_SOURCE[0]}"
    elif [ -n "$ZSH_NAME" ] && [ -n "${(%):-%x}" ]; then
        # in zsh use prompt-style expansion to introspect the same information
        # see http://stackoverflow.com/questions/9901210/bash-source0-equivalent-in-zsh
        # shellcheck disable=SC2296  # bad '(' is guarded
        basename "${(%):-%x}"
    else
        echo "UNKNOWN FILE"
    fi
}

# The arguments to this are:
# 1. activation nature {activate|deactivate}
# 2. toolchain nature {build|host|ccc}
# 3. machine (should match -dumpmachine)
# 4. prefix (including any final -)
# 5+ program (or environment var comma value)
# The format for 5+ is name{,,value}. If value is specified
#  then name taken to be an environment variable, otherwise
#  it is taken to be a program. In this case, which is used
#  to find the full filename during activation. The original
#  value is stored in environment variable CONDA_BACKUP_NAME
#  For deactivation, the distinction is irrelevant as in all
#  cases NAME simply gets reset to CONDA_BACKUP_NAME.  It is
#  a fatal error if a program is identified but not present.
_tc_activation() {
  local act_nature="$1"; shift
  local tc_prefix="$1"; shift
  local thing
  local newval
  local from
  local to
  local pass

  if [ "${act_nature}" = "activate" ]; then
    from=""
    to="CONDA_BACKUP_"
  else
    from="CONDA_BACKUP_"
    to=""
  fi

  for pass in check apply; do
    for thing in "$@"; do
      case "${thing}" in
        *,*)
          newval=$(echo "${thing}" | sed "s,^[^\,]*\,\(.*\),\1,")
          thing=$(echo "${thing}" | sed "s,^\([^\,]*\)\,.*,\1,")
          ;;
        *)
          newval="${CONDA_PREFIX}/bin/${tc_prefix}${thing}"
          thing=$(echo "${thing}" | tr 'a-z+-' 'A-ZX_')
          if [ ! -x "${newval}" ] && [ "${pass}" = "check" ]; then
            echo "ERROR: This cross-compiler package contains no program ${newval}"
            return 1
          fi
          ;;
      esac
      if [ "${pass}" = "apply" ]; then
        eval oldval="\$${from}$thing"
        if [ -n "${oldval}" ]; then
          eval export "${to}'${thing}'=\"${oldval}\""
        else
          eval unset '${to}${thing}'
        fi
        if [ -n "${newval}" ]; then
          eval export "'${from}${thing}=${newval}'"
        else
          eval unset '${from}${thing}'
        fi
      fi
    done
  done
  return 0
}

# The compiler adds $PREFIX/lib to rpath, so it's better to add -L and -isystem  as well.
if [ "${CONDA_BUILD:-0}" = "1" ]; then
  CFLAGS_USED="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem ${PREFIX}/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
  DEBUG_CFLAGS_USED="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe -isystem ${PREFIX}/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
  LDFLAGS_USED="-Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,--gc-sections -Wl,--allow-shlib-undefined -Wl,-rpath,${PREFIX}/lib -Wl,-rpath-link,${PREFIX}/lib -L${PREFIX}/lib"
  CPPFLAGS_USED="-DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem ${PREFIX}/include"
  DEBUG_CPPFLAGS_USED="-D_DEBUG -D_FORTIFY_SOURCE=2 -Og -isystem ${PREFIX}/include"
  CMAKE_PREFIX_PATH_USED="${PREFIX}:${CONDA_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr"
else
  CFLAGS_USED="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem ${CONDA_PREFIX}/include"
  DEBUG_CFLAGS_USED="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe -isystem ${CONDA_PREFIX}/include"
  CPPFLAGS_USED="-DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem ${CONDA_PREFIX}/include"
  DEBUG_CPPFLAGS_USED="-D_DEBUG -D_FORTIFY_SOURCE=2 -Og -isystem ${CONDA_PREFIX}/include"
  LDFLAGS_USED="-Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,--gc-sections -Wl,--allow-shlib-undefined -Wl,-rpath,${CONDA_PREFIX}/lib -Wl,-rpath-link,${CONDA_PREFIX}/lib -L${CONDA_PREFIX}/lib"
  CMAKE_PREFIX_PATH_USED="${CONDA_PREFIX}:${CONDA_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr"
fi

if [ "${CONDA_BUILD:-0}" = "1" ]; then
  if [ -f /tmp/old-env-$$.txt ]; then
    rm -f /tmp/old-env-$$.txt || true
  fi
  env > /tmp/old-env-$$.txt
fi

_CONDA_PYTHON_SYSCONFIGDATA_NAME_USED=${_CONDA_PYTHON_SYSCONFIGDATA_NAME:-_sysconfigdata_x86_64_conda_cos6_linux_gnu}
if [ -n "${_CONDA_PYTHON_SYSCONFIGDATA_NAME_USED}" ] && [ -n "${SYS_SYSROOT}" ]; then
  if find "$(dirname "$(dirname "${SYS_PYTHON}")")/lib/"python* -type f -name "${_CONDA_PYTHON_SYSCONFIGDATA_NAME_USED}.py" -exec false {} +; then
    echo ""
    echo "WARNING: The Python interpreter at the following prefix:"
    echo "         $(dirname "$(dirname "${SYS_PYTHON}")")"
    echo "         .. is not able to handle sysconfigdata-based compilation for the host:"
    echo "         $( printf %s "${_CONDA_PYTHON_SYSCONFIGDATA_NAME_USED}" | sed s/_sysconfigdata_//g )"
    echo ""
    echo "         We are not preventing things from continuing here, but *this* Python will not"
    echo "         be able to compile software for this host, and, depending on whether it has"
    echo "         been patched to ignore missing _CONDA_PYTHON_SYSCONFIGDATA_NAME or not, may cause"
    echo "         an exception."
    echo ""
    echo "         This can happen for one of three reasons:"
    echo ""
    echo "         1. It is out of date: Please run 'conda update python' in that environment"
    echo ""
    echo "         2. You are bootstrapping a sysconfigdata-based cross-capable Python and can ignore this"
    echo "            (but please remember to copy the generated sysconfigdata back to the Python recipe's"
    echo "             sysconfigdate folder and then rebuild it for all the systems you want to be able"
    echo "             to use as a build machine for this host)."
    echo ""
    echo "         3. You are attempting your own bespoke cross-compilation host that is not supported. Have"
    echo "            you provided your own value in the _CONDA_PYTHON_SYSCONFIGDATA_NAME environment variable but"
    echo "            misspelt it and/or failed to add the neccessary ${_CONDA_PYTHON_SYSCONFIGDATA_NAME_USED}.py"
    echo "            file to the Python interpreter's standard library?"
    echo ""
  fi
fi

_CMAKE_ARGS="-DCMAKE_AR=${CONDA_PREFIX}/bin/x86_64-conda-linux-gnu-ar -DCMAKE_CXX_COMPILER_AR=${CONDA_PREFIX}/bin/x86_64-conda-linux-gnu-gcc-ar -DCMAKE_C_COMPILER_AR=${CONDA_PREFIX}/bin/x86_64-conda-linux-gnu-gcc-ar"
_CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_RANLIB=${CONDA_PREFIX}/bin/x86_64-conda-linux-gnu-ranlib -DCMAKE_CXX_COMPILER_RANLIB=${CONDA_PREFIX}/bin/x86_64-conda-linux-gnu-gcc-ranlib -DCMAKE_C_COMPILER_RANLIB=${CONDA_PREFIX}/bin/x86_64-conda-linux-gnu-gcc-ranlib"
_CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_LINKER=${CONDA_PREFIX}/bin/x86_64-conda-linux-gnu-ld -DCMAKE_STRIP=${CONDA_PREFIX}/bin/x86_64-conda-linux-gnu-strip"

if [ "${CONDA_BUILD:-0}" = "1" ]; then
  _CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY"
  _CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_FIND_ROOT_PATH=$PREFIX;${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot"
  _CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=lib"
  _CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_PROGRAM_PATH=${BUILD_PREFIX}/bin;$PREFIX/bin"
fi

# shellcheck disable=SC2050 # templating will fix this error
if [ "" = "1" ]; then
  _CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=x86_64"
fi

_tc_activation \
  activate x86_64-conda-linux-gnu- "HOST,x86_64-conda-linux-gnu" "BUILD,x86_64-conda-linux-gnu" \
  "CONDA_TOOLCHAIN_HOST,x86_64-conda-linux-gnu" \
  "CONDA_TOOLCHAIN_BUILD,x86_64-conda-linux-gnu" \
  cc cpp gcc gcc-ar gcc-nm gcc-ranlib \
  "CPPFLAGS,${CPPFLAGS_USED}${CPPFLAGS:+ }${CPPFLAGS:-}" \
  "CFLAGS,${CFLAGS_USED}${CFLAGS:+ }${CFLAGS:-}" \
  "LDFLAGS,${LDFLAGS_USED}${LDFLAGS:+ }${LDFLAGS:-}" \
  "DEBUG_CPPFLAGS,${DEBUG_CPPFLAGS_USED}${DEBUG_CPPFLAGS:+ }${DEBUG_CPPFLAGS:-}" \
  "DEBUG_CFLAGS,${DEBUG_CFLAGS_USED}${DEBUG_CFLAGS:+ }${DEBUG_CFLAGS:-}" \
  "CMAKE_PREFIX_PATH,${CMAKE_PREFIX_PATH_USED}" \
  "_CONDA_PYTHON_SYSCONFIGDATA_NAME,${_CONDA_PYTHON_SYSCONFIGDATA_NAME_USED}" \
  "CONDA_BUILD_SYSROOT,${CONDA_PREFIX}/x86_64-conda-linux-gnu/sysroot" \
  "CONDA_BUILD_CROSS_COMPILATION," \
  "CC_FOR_BUILD,${CONDA_PREFIX}/bin/x86_64-conda-linux-gnu-cc" \
  "build_alias,x86_64-conda-linux-gnu" \
  "host_alias,x86_64-conda-linux-gnu" \
  "CMAKE_ARGS,${_CMAKE_ARGS}"
oldval=$HOST
unset ${to}${thing}
export 'HOST=x86_64-conda-linux-gnu'
oldval=$BUILD
unset ${to}${thing}
export 'BUILD=x86_64-conda-linux-gnu'
oldval=$CONDA_TOOLCHAIN_HOST
unset ${to}${thing}
export 'CONDA_TOOLCHAIN_HOST=x86_64-conda-linux-gnu'
oldval=$CONDA_TOOLCHAIN_BUILD
unset ${to}${thing}
export 'CONDA_TOOLCHAIN_BUILD=x86_64-conda-linux-gnu'
oldval=$CC
unset ${to}${thing}
export 'CC=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-cc'
oldval=$CPP
unset ${to}${thing}
export 'CPP=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-cpp'
oldval=$GCC
unset ${to}${thing}
export 'GCC=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-gcc'
oldval=$GCC_AR
unset ${to}${thing}
export 'GCC_AR=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-gcc-ar'
oldval=$GCC_NM
unset ${to}${thing}
export 'GCC_NM=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-gcc-nm'
oldval=$GCC_RANLIB
unset ${to}${thing}
export 'GCC_RANLIB=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-gcc-ranlib'
oldval=$CPPFLAGS
unset ${to}${thing}
export 'CPPFLAGS=-DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem /hpc/users/wilsoa28/.conda/envs/diffexpr/include'
oldval=$CFLAGS
unset ${to}${thing}
export 'CFLAGS=-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /hpc/users/wilsoa28/.conda/envs/diffexpr/include'
oldval=$LDFLAGS
unset ${to}${thing}
export 'LDFLAGS=-Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,--gc-sections -Wl,--allow-shlib-undefined -Wl,-rpath,/hpc/users/wilsoa28/.conda/envs/diffexpr/lib -Wl,-rpath-link,/hpc/users/wilsoa28/.conda/envs/diffexpr/lib -L/hpc/users/wilsoa28/.conda/envs/diffexpr/lib'
oldval=$DEBUG_CPPFLAGS
unset ${to}${thing}
export 'DEBUG_CPPFLAGS=-D_DEBUG -D_FORTIFY_SOURCE=2 -Og -isystem /hpc/users/wilsoa28/.conda/envs/diffexpr/include'
oldval=$DEBUG_CFLAGS
unset ${to}${thing}
export 'DEBUG_CFLAGS=-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe -isystem /hpc/users/wilsoa28/.conda/envs/diffexpr/include'
oldval=$CMAKE_PREFIX_PATH
unset ${to}${thing}
export 'CMAKE_PREFIX_PATH=/hpc/users/wilsoa28/.conda/envs/diffexpr:/hpc/users/wilsoa28/.conda/envs/diffexpr/x86_64-conda-linux-gnu/sysroot/usr'
oldval=$_CONDA_PYTHON_SYSCONFIGDATA_NAME
unset ${to}${thing}
export '_CONDA_PYTHON_SYSCONFIGDATA_NAME=_sysconfigdata_x86_64_conda_cos6_linux_gnu'
oldval=$CONDA_BUILD_SYSROOT
unset ${to}${thing}
export 'CONDA_BUILD_SYSROOT=/hpc/users/wilsoa28/.conda/envs/diffexpr/x86_64-conda-linux-gnu/sysroot'
oldval=$CONDA_BUILD_CROSS_COMPILATION
unset ${to}${thing}
unset ${from}${thing}
oldval=$CC_FOR_BUILD
unset ${to}${thing}
export 'CC_FOR_BUILD=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-cc'
oldval=$build_alias
unset ${to}${thing}
export 'build_alias=x86_64-conda-linux-gnu'
oldval=$host_alias
unset ${to}${thing}
export 'host_alias=x86_64-conda-linux-gnu'
oldval=$CMAKE_ARGS
unset ${to}${thing}
export 'CMAKE_ARGS=-DCMAKE_AR=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-ar -DCMAKE_CXX_COMPILER_AR=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-gcc-ar -DCMAKE_C_COMPILER_AR=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-gcc-ar -DCMAKE_RANLIB=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-ranlib -DCMAKE_CXX_COMPILER_RANLIB=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-gcc-ranlib -DCMAKE_C_COMPILER_RANLIB=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-gcc-ranlib -DCMAKE_LINKER=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-ld -DCMAKE_STRIP=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-strip'

unset _CMAKE_ARGS

# shellcheck disable=SC2050 # templating will fix this error
if [ "" = "1" ]; then
_tc_activation \
   activate x86_64-conda-linux-gnu- \
   "QEMU_LD_PREFIX,${QEMU_LD_PREFIX:-${CONDA_BUILD_SYSROOT}}"
fi

if [ $? -ne 0 ]; then
  echo "ERROR: $(_get_sourced_filename) failed, see above for details"
else
  if [ "${CONDA_BUILD:-0}" = "1" ]; then
    if [ -f /tmp/new-env-$$.txt ]; then
      rm -f /tmp/new-env-$$.txt || true
    fi
    env > /tmp/new-env-$$.txt

    echo "INFO: $(_get_sourced_filename) made the following environmental changes:"
    diff -U 0 -rN /tmp/old-env-$$.txt /tmp/new-env-$$.txt | tail -n +4 | grep "^-.*\|^+.*" | grep -v "CONDA_BACKUP_" | sort
    rm -f /tmp/old-env-$$.txt /tmp/new-env-$$.txt || true
  fi

  # fix prompt for zsh
  if [ -n "${ZSH_NAME:-}" ]; then
    autoload -Uz add-zsh-hook

    _conda_clang_precmd() {
      # shellcheck disable=SC2034 # guarded for zsh
      HOST="${CONDA_BACKUP_HOST}"
    }
    add-zsh-hook -Uz precmd _conda_clang_precmd

    _conda_clang_preexec() {
      # shellcheck disable=SC2034 # guarded for zsh
      HOST="${CONDA_TOOLCHAIN_HOST}"
    }
    add-zsh-hook -Uz preexec _conda_clang_preexec
  fi
fi
. "/hpc/users/wilsoa28/.conda/envs/diffexpr/etc/conda/activate.d/activate-gfortran_linux-64.sh"
# shellcheck shell=sh

# This function takes no arguments
# It tries to determine the name of this file in a programatic way.
_get_sourced_filename() {
    # shellcheck disable=SC3054,SC2296 # non-POSIX array access and bad '(' are guarded
    if [ -n "${BASH_SOURCE+x}" ] && [ -n "${BASH_SOURCE[0]}" ]; then
        # shellcheck disable=SC3054 # non-POSIX array access is guarded
        basename "${BASH_SOURCE[0]}"
    elif [ -n "$ZSH_NAME" ] && [ -n "${(%):-%x}" ]; then
        # in zsh use prompt-style expansion to introspect the same information
        # see http://stackoverflow.com/questions/9901210/bash-source0-equivalent-in-zsh
        # shellcheck disable=SC2296  # bad '(' is guarded
        basename "${(%):-%x}"
    else
        echo "UNKNOWN FILE"
    fi
}

# The arguments to this are:
# 1. activation nature {activate|deactivate}
# 2. toolchain nature {build|host|ccc}
# 3. machine (should match -dumpmachine)
# 4. prefix (including any final -)
# 5+ program (or environment var comma value)
# The format for 5+ is name{,,value}. If value is specified
#  then name taken to be an environment variable, otherwise
#  it is taken to be a program. In this case, which is used
#  to find the full filename during activation. The original
#  value is stored in environment variable CONDA_BACKUP_NAME
#  For deactivation, the distinction is irrelevant as in all
#  cases NAME simply gets reset to CONDA_BACKUP_NAME.  It is
#  a fatal error if a program is identified but not present.
_tc_activation() {
  local act_nature="$1"; shift
  local tc_prefix="$1"; shift
  local thing
  local newval
  local from
  local to
  local pass

  if [ "${act_nature}" = "activate" ]; then
    from=""
    to="CONDA_BACKUP_"
  else
    from="CONDA_BACKUP_"
    to=""
  fi

  for pass in check apply; do
    for thing in "$@"; do
      case "${thing}" in
        *,*)
          newval=$(echo "${thing}" | sed "s,^[^\,]*\,\(.*\),\1,")
          thing=$(echo "${thing}" | sed "s,^\([^\,]*\)\,.*,\1,")
          ;;
        *)
          newval="${CONDA_PREFIX}/bin/${tc_prefix}${thing}"
          if [ ! -x "${newval}" ] && [ "${pass}" = "check" ]; then
            echo "ERROR: This cross-compiler package contains no program ${newval}"
            return 1
          fi
          ;;
      esac
      if [ "${pass}" = "apply" ]; then
        thing=$(echo "${thing}" | tr 'a-z+-' 'A-ZX_')
        eval oldval="\$${from}$thing"
        if [ -n "${oldval}" ]; then
          eval export "${to}'${thing}'=\"${oldval}\""
        else
          eval unset '${to}${thing}'
        fi
        if [ -n "${newval}" ]; then
          eval export "'${from}${thing}=${newval}'"
        else
          eval unset '${from}${thing}'
        fi
      fi
    done
  done
  return 0
}

# When people are using conda-build, assume that adding rpath during build, and pointing at
#    the host env's includes and libs is helpful default behavior
if [ "${CONDA_BUILD:-0}" = "1" ]; then
  FFLAGS_USED="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem ${PREFIX}/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
else
  FFLAGS_USED="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem ${CONDA_PREFIX}/include"
fi

if [ "${CONDA_BUILD:-0}" = "1" ]; then
  if [ -f /tmp/old-env-$$.txt ]; then
    rm -f /tmp/old-env-$$.txt || true
  fi
  env > /tmp/old-env-$$.txt
fi

_tc_activation \
  activate x86_64-conda-linux-gnu- \
  gfortran f95 \
  "FC_FOR_BUILD,${CONDA_PREFIX}/bin/x86_64-conda-linux-gnu-gfortran" \
  "FFLAGS,${FFLAGS_USED}${FFLAGS:+ }${FFLAGS:-}" \
  "FORTRANFLAGS,${FFLAGS_USED}${FORTRANFLAGS:+ }${FORTRANFLAGS:-}" \
  "DEBUG_FFLAGS,${FFLAGS_USED} -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments -ffunction-sections -pipe${FFLAGS:+ }${FFLAGS:-}" \
  "DEBUG_FORTRANFLAGS,${FFLAGS_USED} -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments -ffunction-sections -pipe${FORTRANFLAGS:+ }${FORTRANFLAGS:-}" \

oldval=$GFORTRAN
unset ${to}${thing}
export 'GFORTRAN=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-gfortran'
oldval=$F95
unset ${to}${thing}
export 'F95=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-f95'
oldval=$FC_FOR_BUILD
unset ${to}${thing}
export 'FC_FOR_BUILD=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-gfortran'
oldval=$FFLAGS
unset ${to}${thing}
export 'FFLAGS=-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /hpc/users/wilsoa28/.conda/envs/diffexpr/include'
oldval=$FORTRANFLAGS
unset ${to}${thing}
export 'FORTRANFLAGS=-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /hpc/users/wilsoa28/.conda/envs/diffexpr/include'
oldval=$DEBUG_FFLAGS
unset ${to}${thing}
export 'DEBUG_FFLAGS=-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /hpc/users/wilsoa28/.conda/envs/diffexpr/include -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments -ffunction-sections -pipe'
oldval=$DEBUG_FORTRANFLAGS
unset ${to}${thing}
export 'DEBUG_FORTRANFLAGS=-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /hpc/users/wilsoa28/.conda/envs/diffexpr/include -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments -ffunction-sections -pipe'
# extra ones - have a dependency on the previous ones, so done after.
_tc_activation \
  activate x86_64-conda-linux-gnu- \
  "FC,${FC:-${GFORTRAN}}" \
  "F77,${F77:-${GFORTRAN}}" \
  "F90,${F90:-${GFORTRAN}}"
oldval=$FC
unset ${to}${thing}
export 'FC=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-gfortran'
oldval=$F77
unset ${to}${thing}
export 'F77=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-gfortran'
oldval=$F90
unset ${to}${thing}
export 'F90=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-gfortran'

if [ $? -ne 0 ]; then
  echo "ERROR: $(_get_sourced_filename) failed, see above for details"
else
  if [ "${CONDA_BUILD:-0}" = "1" ]; then
    if [ -f /tmp/new-env-$$.txt ]; then
      rm -f /tmp/new-env-$$.txt || true
    fi
    env > /tmp/new-env-$$.txt

    echo "INFO: $(_get_sourced_filename) made the following environmental changes:"
    diff -U 0 -rN /tmp/old-env-$$.txt /tmp/new-env-$$.txt | tail -n +4 | grep "^-.*\|^+.*" | grep -v "CONDA_BACKUP_" | sort
    rm -f /tmp/old-env-$$.txt /tmp/new-env-$$.txt || true
  fi
fi
. "/hpc/users/wilsoa28/.conda/envs/diffexpr/etc/conda/activate.d/activate-gxx_linux-64.sh"
# shellcheck shell=sh

# This function takes no arguments
# It tries to determine the name of this file in a programatic way.
_get_sourced_filename() {
    # shellcheck disable=SC3054,SC2296 # non-POSIX array access and bad '(' are guarded
    if [ -n "${BASH_SOURCE+x}" ] && [ -n "${BASH_SOURCE[0]}" ]; then
        # shellcheck disable=SC3054 # non-POSIX array access is guarded
        basename "${BASH_SOURCE[0]}"
    elif [ -n "$ZSH_NAME" ] && [ -n "${(%):-%x}" ]; then
        # in zsh use prompt-style expansion to introspect the same information
        # see http://stackoverflow.com/questions/9901210/bash-source0-equivalent-in-zsh
        # shellcheck disable=SC2296  # bad '(' is guarded
        basename "${(%):-%x}"
    else
        echo "UNKNOWN FILE"
    fi
}

# The arguments to this are:
# 1. activation nature {activate|deactivate}
# 2. toolchain nature {build|host|ccc}
# 3. machine (should match -dumpmachine)
# 4. prefix (including any final -)
# 5+ program (or environment var comma value)
# The format for 5+ is name{,,value}. If value is specified
#  then name taken to be an environment variable, otherwise
#  it is taken to be a program. In this case, which is used
#  to find the full filename during activation. The original
#  value is stored in environment variable CONDA_BACKUP_NAME
#  For deactivation, the distinction is irrelevant as in all
#  cases NAME simply gets reset to CONDA_BACKUP_NAME.  It is
#  a fatal error if a program is identified but not present.
_tc_activation() {
  local act_nature="$1"; shift
  local tc_prefix="$1"; shift
  local thing
  local newval
  local from
  local to
  local pass

  if [ "${act_nature}" = "activate" ]; then
    from=""
    to="CONDA_BACKUP_"
  else
    from="CONDA_BACKUP_"
    to=""
  fi

  for pass in check apply; do
    for thing in "$@"; do
      case "${thing}" in
        *,*)
          newval=$(echo "${thing}" | sed "s,^[^\,]*\,\(.*\),\1,")
          thing=$(echo "${thing}" | sed "s,^\([^\,]*\)\,.*,\1,")
          ;;
        *)
          newval="${CONDA_PREFIX}/bin/${tc_prefix}${thing}"
          if [ ! -x "${newval}" ] && [ "${pass}" = "check" ]; then
            echo "ERROR: This cross-compiler package contains no program ${newval}"
            return 1
          fi
          ;;
      esac
      if [ "${pass}" = "apply" ]; then
        thing=$(echo "${thing}" | tr 'a-z+-' 'A-ZX_')
        eval oldval="\$${from}$thing"
        if [ -n "${oldval}" ]; then
          eval export "${to}'${thing}'=\"${oldval}\""
        else
          eval unset '${to}${thing}'
        fi
        if [ -n "${newval}" ]; then
          eval export "'${from}${thing}=${newval}'"
        else
          eval unset '${from}${thing}'
        fi
      fi
    done
  done
  return 0
}

# When people are using conda-build, assume that adding rpath during build, and pointing at
#    the host env's includes and libs is helpful default behavior
if [ "${CONDA_BUILD:-0}" = "1" ]; then
  CXXFLAGS_USED="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem ${PREFIX}/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
  DEBUG_CXXFLAGS_USED="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe -isystem ${PREFIX}/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
else
  CXXFLAGS_USED="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem ${CONDA_PREFIX}/include"
  DEBUG_CXXFLAGS_USED="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe -isystem ${CONDA_PREFIX}/include"
fi

if [ "${CONDA_BUILD:-0}" = "1" ]; then
  if [ -f /tmp/old-env-$$.txt ]; then
    rm -f /tmp/old-env-$$.txt || true
  fi
  env > /tmp/old-env-$$.txt
fi

_tc_activation \
  activate x86_64-conda-linux-gnu- \
  c++ g++ \
  "CXXFLAGS,${CXXFLAGS_USED}${CXXFLAGS:+ }${CXXFLAGS:-}" \
  "DEBUG_CXXFLAGS,${DEBUG_CXXFLAGS_USED}${DEBUG_CXXFLAGS:+ }${DEBUG_CXXFLAGS:-}" \
  "CXX_FOR_BUILD,${CONDA_PREFIX}/bin/x86_64-conda-linux-gnu-c++"
oldval=$CXX
unset ${to}${thing}
export 'CXX=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-c++'
oldval=$GXX
unset ${to}${thing}
export 'GXX=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-g++'
oldval=$CXXFLAGS
unset ${to}${thing}
export 'CXXFLAGS=-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /hpc/users/wilsoa28/.conda/envs/diffexpr/include'
oldval=$DEBUG_CXXFLAGS
unset ${to}${thing}
export 'DEBUG_CXXFLAGS=-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe -isystem /hpc/users/wilsoa28/.conda/envs/diffexpr/include'
oldval=$CXX_FOR_BUILD
unset ${to}${thing}
export 'CXX_FOR_BUILD=/hpc/users/wilsoa28/.conda/envs/diffexpr/bin/x86_64-conda-linux-gnu-c++'

if [ $? -ne 0 ]; then
  echo "ERROR: $(_get_sourced_filename) failed, see above for details"
#exit 1
else
  if [ "${CONDA_BUILD:-0}" = "1" ]; then
    if [ -f /tmp/new-env-$$.txt ]; then
      rm -f /tmp/new-env-$$.txt || true
    fi
    env > /tmp/new-env-$$.txt

    echo "INFO: $(_get_sourced_filename) made the following environmental changes:"
    diff -U 0 -rN /tmp/old-env-$$.txt /tmp/new-env-$$.txt | tail -n +4 | grep "^-.*\|^+.*" | grep -v "CONDA_BACKUP_" | sort
    rm -f /tmp/old-env-$$.txt /tmp/new-env-$$.txt || true
  fi
fi
. "/hpc/users/wilsoa28/.conda/envs/diffexpr/etc/conda/activate.d/activate-r-base.sh"
#!/usr/bin/env sh
R CMD javareconf > /dev/null 2>&1 || true

# store existing RSTUDIO_WHICH_R
if [[ ! -z ${RSTUDIO_WHICH_R+x} ]]; then
  export RSTUDIO_WHICH_R_PREV="$RSTUDIO_WHICH_R"
fi
export RSTUDIO_WHICH_R="$CONDA_PREFIX/bin/R"
. "/hpc/users/wilsoa28/.conda/envs/diffexpr/etc/conda/activate.d/libglib_activate.sh"
export GSETTINGS_SCHEMA_DIR_CONDA_BACKUP="${GSETTINGS_SCHEMA_DIR:-}"
export GSETTINGS_SCHEMA_DIR="$CONDA_PREFIX/share/glib-2.0/schemas"

# 01b. Get root directory
exec_dir=$( pwd )
cd "${exec_dir}"
sud_dea_dir="${exec_dir}/scripts"

# 02. Set up config files
# 02a. Specify config file path
cfg="${exec_dir}/configs/config_run_DESeq2_example_SUD_DEA.yaml"
echo "${cfg}"
# 02b. Add root directory to config file if not specified
if ! $( grep -q 'root_dir' ${cfg} ); then
	echo "Initializing config file with current directory as root directory"
	echo "root_dir: '${exec_dir}'" >> ${cfg}
else
	echo "Config file already contains root directory; proceeding"
fi

# 03. Specify cell type(s) being processed (separately) with DESeq2 (comma-separated list)
group="dopaminergic_neuron"

# 04. Run DEA
# 04a. Specify random seed file locations
rs_dir="${exec_dir}/data/random_state_files/dea_random_seed_files"
rs_fn_tag="sud"
# 04b. Specify number of folds for k-fold cross-validation
nfolds="2"
for fold in $(seq 1 ${nfolds}); do
	rsfn="${rs_dir}/dea_rand_seed__${rs_fn_tag}__${group}__${fold}.txt"
	rscurr=$( cat "${rsfn}" )
	echo -e "Running SUD DEA for fold ${fold} with random seed ${rscurr}"
	python "${sud_dea_dir}/04_run_deseq2_kfcv.py" --config-yaml-path ${cfg} --group-to-process ${group} --fold-to-process ${fold} --rand-seed ${rscurr}
done
WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: converting counts to integer mode

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: estimating size factors

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: estimating dispersions

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: gene-wise dispersion estimates

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: mean-dispersion relationship

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: final dispersion estimates

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: fitting model and testing

INFO:DESeq2:Using contrast: ['hiv_sud_status', 'neg_y', 'neg_n']
INFO:DESeq2:Normalizing counts
WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: Warning message:

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: In DESeqDataSet(se, design = design, ignoreRank) :
WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: 
 
WARNING:rpy2.rinterface_lib.callbacks:R[write to console]:  some variables in design formula are characters, converting to factors

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: converting counts to integer mode

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: estimating size factors

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: estimating dispersions

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: gene-wise dispersion estimates

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: mean-dispersion relationship

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: final dispersion estimates

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: fitting model and testing

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: -- replacing outliers and refitting for 494 genes
-- DESeq argument 'minReplicatesForReplace' = 7 
-- original counts are preserved in counts(dds)

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: estimating dispersions

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: fitting model and testing

INFO:DESeq2:Using contrast: ['hiv_sud_status', 'neg_y', 'neg_n']
INFO:DESeq2:Normalizing counts
WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: Warning message:

WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: In DESeqDataSet(se, design = design, ignoreRank) :
WARNING:rpy2.rinterface_lib.callbacks:R[write to console]: 
 
WARNING:rpy2.rinterface_lib.callbacks:R[write to console]:  some variables in design formula are characters, converting to factors




