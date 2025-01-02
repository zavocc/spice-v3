
/* This file is generated by glib-mkenums, do not modify it. This code is licensed under the same license as the containing project. Note that it links to GLib, so must comply with the LGPL linking clauses. */

#include <config.h>

#include "spice-server-enums.h"

typedef struct EnumValues {
    int value;
    const char *nick;
} EnumValues;

static const char *
enum_values_get_nick(int value, const EnumValues *e)
{
    for (; e->nick; e++) {
        if (e->value == value) {
            return e->nick;
        }
    }
    return "???";
}

const char *spice_compat_version_t_get_nick(spice_compat_version_t value)
{
    static const struct EnumValues spice_compat_version_t_values[] = {
        { SPICE_COMPAT_VERSION_0_4, "4" },
        { SPICE_COMPAT_VERSION_0_6, "6" },
        { 0, NULL, }
    };
    return enum_values_get_nick(value, spice_compat_version_t_values);
}

const char *spice_image_compression_t_get_nick(spice_image_compression_t value)
{
    static const struct EnumValues spice_image_compression_t_values[] = {
        { SPICE_IMAGE_COMPRESSION_INVALID, "invalid" },
        { SPICE_IMAGE_COMPRESSION_OFF, "off" },
        { SPICE_IMAGE_COMPRESSION_AUTO_GLZ, "auto-glz" },
        { SPICE_IMAGE_COMPRESSION_AUTO_LZ, "auto-lz" },
        { SPICE_IMAGE_COMPRESSION_QUIC, "quic" },
        { SPICE_IMAGE_COMPRESSION_GLZ, "glz" },
        { SPICE_IMAGE_COMPRESSION_LZ, "lz" },
        { SPICE_IMAGE_COMPRESSION_LZ4, "lz4" },
        { 0, NULL, }
    };
    return enum_values_get_nick(value, spice_image_compression_t_values);
}

const char *spice_wan_compression_t_get_nick(spice_wan_compression_t value)
{
    static const struct EnumValues spice_wan_compression_t_values[] = {
        { SPICE_WAN_COMPRESSION_INVALID, "invalid" },
        { SPICE_WAN_COMPRESSION_AUTO, "auto" },
        { SPICE_WAN_COMPRESSION_ALWAYS, "always" },
        { SPICE_WAN_COMPRESSION_NEVER, "never" },
        { 0, NULL, }
    };
    return enum_values_get_nick(value, spice_wan_compression_t_values);
}

/* Generated data ends here */

