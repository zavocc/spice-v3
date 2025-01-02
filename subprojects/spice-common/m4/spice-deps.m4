# SPICE_WARNING(warning)
# SPICE_PRINT_MESSAGES
# ----------------------
# Collect warnings and print them at the end so they are clearly visible.
# ---------------------
AC_DEFUN([SPICE_WARNING],[AS_VAR_APPEND([spice_warnings],["|$1"])])
AC_DEFUN([SPICE_PRINT_MESSAGES],[
    ac_save_IFS="$IFS"
    IFS="|"
    for msg in $spice_warnings; do
        IFS="$ac_save_IFS"
        AS_VAR_IF([msg],[],,[AC_MSG_WARN([$msg]); echo >&2])
    done
    IFS="$ac_save_IFS"
])


# SPICE_EXTRA_CHECKS()
# --------------------
# Check for --enable-extra-checks option
# --------------------
AC_DEFUN([SPICE_EXTRA_CHECKS],[
AC_ARG_ENABLE([extra-checks],
               AS_HELP_STRING([--enable-extra-checks=@<:@yes/no@:>@],
                              [Enable expensive checks @<:@default=no@:>@]))
AM_CONDITIONAL(ENABLE_EXTRA_CHECKS, test "x$enable_extra_checks" = "xyes")
AM_COND_IF([ENABLE_EXTRA_CHECKS], AC_DEFINE([ENABLE_EXTRA_CHECKS], 1, [Enable extra checks on code]))
])


# SPICE_CHECK_SYSDEPS()
# ---------------------
# Checks for header files and library functions needed by spice-common.
# ---------------------
AC_DEFUN([SPICE_CHECK_SYSDEPS], [
    AC_C_BIGENDIAN
    AC_FUNC_ALLOCA
    AC_CHECK_HEADERS([arpa/inet.h netinet/in.h stdlib.h sys/socket.h unistd.h])

    # Checks for typedefs, structures, and compiler characteristics
    AC_C_INLINE

    # Checks for library functions
    # do not check malloc or realloc, since that cannot be cross-compiled checked
    AC_CHECK_FUNCS([floor])
    AC_SEARCH_LIBS([hypot], [m], [], [
        AC_MSG_ERROR([unable to find the hypot() function])
    ])
])


# SPICE_CHECK_SMARTCARD
# ---------------------
# Adds a --enable-smartcard switch in order to enable/disable smartcard
# support, and checks if the needed libraries are available. If found, it will
# return the flags to use in the SMARTCARD_CFLAGS and SMARTCARD_LIBS variables, and
# it will define a USE_SMARTCARD preprocessor symbol as well as a HAVE_SMARTCARD
# Makefile conditional.
#----------------------
AC_DEFUN([SPICE_CHECK_SMARTCARD], [
    AC_ARG_ENABLE([smartcard],
      AS_HELP_STRING([--enable-smartcard=@<:@yes/no/auto@:>@],
                     [Enable smartcard support @<:@default=auto@:>@]),
      [],
      [enable_smartcard="auto"])

    have_smartcard=no
    if test "x$enable_smartcard" != "xno"; then
      PKG_CHECK_MODULES([SMARTCARD], [libcacard >= 2.5.1], [have_smartcard=yes], [have_smartcard=no])
      if test "x$enable_smartcard" = "xyes" && test "x$have_smartcard" = "xno"; then
        AC_MSG_ERROR([smarcard support explicitly requested, but some required packages are not available])
      fi
      if test "x$have_smartcard" = "xyes"; then
        AC_DEFINE(USE_SMARTCARD, [1], [Define if supporting smartcard proxying])
      fi
    fi
    AM_CONDITIONAL(HAVE_SMARTCARD, test "x$have_smartcard" = "xyes")
])


# SPICE_CHECK_OPUS
# ----------------
# Check for the availability of Opus. If found, it will return the flags to use
# in the OPUS_CFLAGS and OPUS_LIBS variables, and it will define a
# HAVE_OPUS preprocessor symbol as well as a HAVE_OPUS Makefile conditional.
# ----------------
AC_DEFUN([SPICE_CHECK_OPUS], [
    AC_ARG_ENABLE([opus],
        [  --disable-opus       Disable Opus audio codec (enabled by default)],,
        [enable_opus="auto"])
    if test "x$enable_opus" != "xno"; then
        PKG_CHECK_MODULES([OPUS], [opus >= 0.9.14], [have_opus=yes], [have_opus=no])
        if test "x$enable_opus" = "xauto" && test "x$have_opus" = "xno"; then
            AC_MSG_ERROR([Opus could not be detected, explicitly use --disable-opus if that's intentional])
        fi
        if test "x$enable_opus" = "xyes" && test "x$have_opus" != "xyes"; then
            AC_MSG_ERROR([--enable-opus has been specified, but Opus is missing])
        fi
    fi

    AM_CONDITIONAL([HAVE_OPUS], [test "x$have_opus" = "xyes"])
    AM_COND_IF([HAVE_OPUS], AC_DEFINE([HAVE_OPUS], [1], [Define if we have OPUS]))
])


# SPICE_CHECK_PIXMAN
# ------------------
# Check for the availability of pixman. If found, it will return the flags to
# use in the PIXMAN_CFLAGS and PIXMAN_LIBS variables.
#-------------------
AC_DEFUN([SPICE_CHECK_PIXMAN], [
    PKG_CHECK_MODULES(PIXMAN, pixman-1 >= 0.17.7)
])


# SPICE_CHECK_GLIB2
# -----------------
# Check for the availability of glib2. If found, it will return the flags to
# use in the GLIB2_CFLAGS and GLIB2_LIBS variables.
#------------------
AC_DEFUN([SPICE_CHECK_GLIB2], [
    PKG_CHECK_MODULES(GLIB2, glib-2.0 >= 2.38)
    PKG_CHECK_MODULES(GIO2, gio-2.0 >= 2.38)
    GLIB2_CFLAGS="$GLIB2_CFLAGS -DGLIB_VERSION_MIN_REQUIRED=GLIB_VERSION_2_38 -DGLIB_VERSION_MAX_ALLOWED=GLIB_VERSION_2_38"
])

# SPICE_CHECK_GDK_PIXBUF
# ----------------------
# Check for the availability of gdk-pixbuf. If found, it will return the flags to use
# in the GDK_PIXBUF_CFLAGS and GDK_PIXBUF_LIBS variables, and it will define a
# HAVE_GDK_PIXBUF preprocessor symbol as well as a HAVE_GDK_PIXBUF Makefile conditional.
# ----------------
AC_DEFUN([SPICE_CHECK_GDK_PIXBUF], [
    PKG_CHECK_MODULES([GDK_PIXBUF], [gdk-pixbuf-2.0 >= 2.26], [have_gdk_pixbuf=yes], [have_gdk_pixbuf=no])

    AM_CONDITIONAL([HAVE_GDK_PIXBUF], [test "x$have_gdk_pixbuf" = "xyes"])
    AM_COND_IF([HAVE_GDK_PIXBUF], AC_DEFINE([HAVE_GDK_PIXBUF], [1], [Define if gdk-pixbuf was found]))
])

# SPICE_CHECK_PYTHON_MODULES()
# --------------------------
# Adds a --enable-python-checks configure flags as well as checks for the
# availability of the python modules needed by the python scripts generating
# C code from spice.proto. These checks are not needed when building from
# tarballs so they are disabled by default.
#---------------------------
AC_DEFUN([SPICE_CHECK_PYTHON_MODULES], [
    AC_ARG_ENABLE([python-checks],
        AS_HELP_STRING([--enable-python-checks=@<:@yes/no@:>@],
                       [Enable checks for Python modules needed to build from git @<:@default=no@:>@]),
                       [],
                       [enable_python_checks="no"])
    if test "x$enable_python_checks" != "xno"; then
        AS_IF([test -n "$PYTHON"], # already set required PYTHON version
              [AM_PATH_PYTHON
               AX_PYTHON_MODULE([six], [1])
               AX_PYTHON_MODULE([pyparsing], [1])],
              [PYTHON=python3
               AX_PYTHON_MODULE([six])
               AX_PYTHON_MODULE([pyparsing])
               test "$HAVE_PYMOD_SIX" = "yes" && test "$HAVE_PYMOD_PYPARSING" = "yes"],
              [AM_PATH_PYTHON([3])],
              [PYTHON=python2
               AX_PYTHON_MODULE([six])
               AX_PYTHON_MODULE([pyparsing])
               test "$HAVE_PYMOD_SIX" = "yes" && test "$HAVE_PYMOD_PYPARSING" = "yes"],
              [AM_PATH_PYTHON([2])],
              [AC_MSG_ERROR([Python modules six and pyparsing are required])])
    else
        AM_PATH_PYTHON
    fi
])


# SPICE_CHECK_LZ4
# ---------------
# Adds a --enable-lz4 switch in order to enable/disable LZ4 compression
# support, and checks if the needed libraries are available. If found, it will
# return the flags to use in the LZ4_CFLAGS and LZ4_LIBS variables, and
# it will define a USE_LZ4 preprocessor symbol and a HAVE_LZ4 conditional.
# ---------------
AC_DEFUN([SPICE_CHECK_LZ4], [
    AC_ARG_ENABLE([lz4],
      AS_HELP_STRING([--enable-lz4=@<:@yes/no/auto@:>@],
                     [Enable LZ4 compression support @<:@default=auto@:>@]),
      [],
      [enable_lz4="auto"])

    have_lz4="no"
    if test "x$enable_lz4" != "xno"; then
      # LZ4_compress_default is available in liblz4 >= 129, however liblz has changed
      # versioning scheme making the check failing. Rather check for function definition
      PKG_CHECK_MODULES([LZ4], [liblz4], [have_lz4="yes"], [have_lz4="no"])

      if test "x$have_lz4" = "xyes"; then
        # It is necessary to set LIBS and CFLAGS before AC_CHECK_FUNC
        old_LIBS="$LIBS"
        old_CFLAGS="$CFLAGS"
        CFLAGS="$CFLAGS $LZ4_CFLAGS"
        LIBS="$LIBS $LZ4_LIBS"

        AC_CHECK_FUNC([LZ4_compress_default], [
            AC_DEFINE(USE_LZ4, [1], [Define to build with lz4 support])],
            [have_lz4="no"])
        AC_CHECK_FUNCS([LZ4_compress_fast_continue])

        LIBS="$old_LIBS"
        CFLAGS="$old_CFLAGS"
      fi
      if test "x$enable_lz4" = "xyes" && test "x$have_lz4" = "xno"; then
        AC_MSG_ERROR([lz4 support requested but liblz4 >= 129 could not be found])
      fi
    fi
    AM_CONDITIONAL(HAVE_LZ4, test "x$have_lz4" = "xyes")
])


# SPICE_CHECK_GSTREAMER(VAR, version, packages-to-check-for, [action-if-found, [action-if-not-found]])
# ---------------------
# Checks whether the specified GStreamer modules are present and sets the
# corresponding autoconf variables and preprocessor definitions.
# ---------------------
AC_DEFUN([SPICE_CHECK_GSTREAMER], [
    AS_VAR_PUSHDEF([have_gst],[have_]m4_tolower([$1]))dnl
    AS_VAR_PUSHDEF([gst_inspect],[GST_INSPECT_$2])dnl
    PKG_CHECK_MODULES([$1], [$3],
        [have_gst="yes"
         AC_SUBST(AS_TR_SH([[$1]_CFLAGS]))
         AC_SUBST(AS_TR_SH([[$1]_LIBS]))
         AS_VAR_APPEND([SPICE_REQUIRES], [" $3"])
         AC_DEFINE(AS_TR_SH([HAVE_$1]), [1], [Define if supporting GStreamer $2])
         AC_PATH_PROG(gst_inspect, gst-inspect-$2)
         AS_IF([test "x$gst_inspect" = x],
               SPICE_WARNING([Cannot verify that the required runtime GStreamer $2 elements are present because gst-inspect-$2 is missing]))
         $4],
        [have_gst="no"
         $5])
    AS_VAR_POPDEF([gst_inspect])dnl
    AS_VAR_POPDEF([have_gst])dnl
])

# SPICE_CHECK_GSTREAMER_ELEMENTS(gst-inspect, package, elements-to-check-for)
# ---------------------
# Checks that the specified GStreamer elements are installed. If not it
# issues a warning and sets missing_gstreamer_elements.
# ---------------------
AC_DEFUN([SPICE_CHECK_GSTREAMER_ELEMENTS], [
AS_IF([test "x$1" != x],
      [missing=""
       for element in $3
       do
           AS_VAR_PUSHDEF([cache_var],[spice_cv_prog_${1}_${element}])dnl
           AC_CACHE_CHECK([for the $element GStreamer element], cache_var,
                          [found=no
                           "$1" $element >/dev/null 2>/dev/null && found=yes
                           eval "cache_var=$found"])
           AS_VAR_COPY(res, cache_var)
           AS_IF([test "x$res" = "xno"], [missing="$missing $element"])
           AS_VAR_POPDEF([cache_var])dnl
       done
       AS_IF([test "x$missing" != x],
             [SPICE_WARNING([The$missing GStreamer element(s) are missing. You should be able to find them in the $2 package.])
              missing_gstreamer_elements="yes"],
             [test "x$missing_gstreamer_elements" = x],
             [missing_gstreamer_elements="no"])
      ])
])

# SPICE_CHECK_SASL
# ----------------
# Adds a --with-sasl switch to allow using SASL for authentication.
# Checks whether the required library is available. If it is present,
# it will return the flags to use in SASL_CFLAGS and SASL_LIBS variables,
# and it will define a have_sasl configure variable and a HAVE_SASL preprocessor
# symbol.
# ----------------
AC_DEFUN([SPICE_CHECK_SASL], [
    AC_ARG_WITH([sasl],
      [AS_HELP_STRING([--with-sasl=@<:@yes/no/auto@:>@],
                      [use cyrus SASL for authentication @<:@default=auto@:>@])],
                      [],
                      [with_sasl="auto"])

    have_sasl=no
    if test "x$with_sasl" != "xno"; then
      PKG_CHECK_MODULES([SASL], [libsasl2], [have_sasl=yes],[have_sasl=no])
      if test "x$have_sasl" = "xno" && test "x$with_sasl" = "xyes"; then
        AC_MSG_ERROR([Cyrus SASL support requested but libsasl2 could not be found])
      fi
      if test "x$have_sasl" = "xyes"; then
        AC_DEFINE([HAVE_SASL], 1, [whether Cyrus SASL is available for authentication])
      fi
    fi
])

# SPICE_CHECK_OPENSSL
# -----------------
# Check for the availability of openssl. If found, it will return the flags to
# use in the OPENSSL_CFLAGS and OPENSSL_LIBS variables.
#------------------
AC_DEFUN([SPICE_CHECK_OPENSSL], [
    PKG_CHECK_MODULES(OPENSSL, openssl)
])

# SPICE_CHECK_INSTRUMENTATION
# -----------------
# Check for the availability of an instrumentation library.
#------------------
AC_DEFUN([SPICE_CHECK_INSTRUMENTATION], [
    AC_ARG_ENABLE([instrumentation],
      AS_HELP_STRING([--enable-instrumentation=@<:@recorder/agent/no@:>@],
                     [Enable instrumentation @<:@default=no@:>@]),
      [],
      enable_instrumentation="no")
    AS_IF([test "$enable_instrumentation" = "recorder"],
           AC_DEFINE([ENABLE_RECORDER], [1], [Define if the recorder instrumentation is enabled]))
    AS_IF([test "$enable_instrumentation" = "agent"],
           AC_DEFINE([ENABLE_AGENT_INTERFACE], [1], [Define if the agent-interface instrumentation is enabled]))
    AM_CONDITIONAL([ENABLE_RECORDER],[test "$enable_instrumentation" = "recorder"])
    AM_CONDITIONAL([ENABLE_AGENT_INTERFACE],[test "$enable_instrumentation" = "agent"])
])

# SPICE_COMMON
# -----------------
# Define variables in order to use spice-common
# SPICE_COMMON_DIR        directory for output libraries
# SPICE_COMMON_CFLAGS     CFLAGS to add to use the library
#
# SPICE_PROTOCOL_MIN_VER  input (m4) and output (autoconf) SPICE protocol version
# SPICE_PROTOCOL_CFLAGS   CFLAGS for SPICE protocol, already automatically included
#
# GLIB2_MIN_VER           input (m4) and output (shell) GLib2 minimum version
# GLIB2_MIN_VERSION       output (shell) variable like "GLIB_VERSION_1_2" from GLIB2_MIN_VER
#------------------
AC_DEFUN([SPICE_COMMON], [dnl
dnl These add some flags and checks to component using spice-common
dnl The flags are necessary in order to make included header working
    AC_REQUIRE([SPICE_EXTRA_CHECKS])dnl
    AC_REQUIRE([SPICE_CHECK_INSTRUMENTATION])dnl
dnl Get the required spice protocol version
    m4_define([SPICE_PROTOCOL_MIN_VER],m4_ifdef([SPICE_PROTOCOL_MIN_VER],SPICE_PROTOCOL_MIN_VER,[0.14.2]))dnl
    m4_define([SPICE_PROTOCOL_MIN_VER],m4_if(m4_version_compare(SPICE_PROTOCOL_MIN_VER,[0.14.2]),[1],SPICE_PROTOCOL_MIN_VER,[0.14.2]))dnl
    [SPICE_PROTOCOL_MIN_VER]=SPICE_PROTOCOL_MIN_VER
    m4_undefine([SPICE_PROTOCOL_MIN_VER])dnl
    PKG_CHECK_MODULES([SPICE_PROTOCOL], [spice-protocol >= $SPICE_PROTOCOL_MIN_VER])
    AC_SUBST([SPICE_PROTOCOL_MIN_VER])dnl
dnl Get the required GLib2 version
    m4_define([GLIB2_MIN_VER],m4_ifdef([GLIB2_MIN_VER],GLIB2_MIN_VER,[2.38]))dnl
    m4_define([GLIB2_MIN_VER],m4_if(m4_version_compare(GLIB2_MIN_VER,[2.38]),[1],GLIB2_MIN_VER,[2.38]))dnl
    m4_define([GLIB2_MIN_VERSION],[GLIB_VERSION_]m4_translit(GLIB2_MIN_VER,[.],[_]))dnl
    [GLIB2_MIN_VER]=GLIB2_MIN_VER
    [GLIB2_MIN_VERSION]=GLIB2_MIN_VERSION
    m4_undefine([GLIB2_MIN_VER])dnl
    m4_undefine([GLIB2_MIN_VERSION])dnl
    PKG_CHECK_MODULES([GLIB2], [glib-2.0 >= $GLIB2_MIN_VER gio-2.0 >= $GLIB2_MIN_VER])
dnl Configuration variables
    AC_CONFIG_SUBDIRS([$1])dnl
    SPICE_COMMON_CFLAGS='-I${top_srcdir}/$1 -I${top_builddir}/$1 -DG_LOG_DOMAIN=\"Spice\" $(SPICE_PROTOCOL_CFLAGS) $(GLIB2_CFLAGS)'
    AC_SUBST([SPICE_COMMON_CFLAGS])dnl

    SPICE_COMMON_DIR='${top_builddir}/$1'
    AC_SUBST([SPICE_COMMON_DIR])dnl
])
