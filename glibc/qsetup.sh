# spack load gmake bison texinfo gettext binutils
BINUTIL_PATH="/home/yizeyi18/soft/spack/opt/spack/linux-ubuntu24.04-skylake/clang-18.1.3/binutils-2.43.1-pdfiav3saot2be5k3jfxqkpneysmhleg"
GLIBC_ROOT="${HOME}/soft/glibc-2.40"
PREFIX="${GLIBC_ROOT}/install"
SAFETY="0"
NO_HIDDEN="0"
if [ "$SAFETY" -eq "0" ]; then
    ENABLE_FOR_SAFETY="disable"
    YES_FOR_SAFETY="no"
    WITH_FOR_SAFETY="without"
else
    ENABLE_FOR_SAFETY="enable"
    YES_FOR_SAFETY="yes"
    WITH_FOR_SAFETY="with"
fi

if [ "$NO_HIDDEN" -eq "1" ]; then
    HIDDEN="${ENABLE_FOR_SAFETY}-hidden-plt"
else
    HIDDEN="enable-hidden-plt"
fi

# TODO: 
#  - Enable memory tagging by default? Does program compiled & used by
#    my self need this?
#  - Enable CET on x86/amd64 by default? Makes subroutine calls slow,
#    maybe bad to some long-call-stack programs like gaussian/molpro

${GLIBC_ROOT}/configure \
 --with-binutils=${BINUTIL_PATH} --without-selinux \
 --enable-kernel=current --${ENABLE_FOR_SAFETY}-memory-tagging \
 --${ENABLE_FOR_SAFETY}-cet --enable-mathvec \
 --enable-stack-protector=${YES_FOR_SAFETY} \
 --${HIDDEN} --enable-profile \
 --enable-shared --prefix=${PREFIX} \
 --enable-fortify-source=${YES_FOR_SAFETY} \
 CFLAGS=" -O3 -g" CXXFLAGS=" -O3 -g"
