/*
   Copyright (C) 2011 Red Hat, Inc.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, see <http://www.gnu.org/licenses/>.

   Red Hat Authors:
        hdegoede@redhat.com
*/
#include <config.h>

#include <string.h>
#include <spice/vd_agent.h>
#include "red-common.h"
#include "agent-msg-filter.h"

void agent_msg_filter_config(AgentMsgFilter *filter,
                             gboolean copy_paste, gboolean file_xfer,
                             gboolean use_client_monitors_config)
{
    filter->copy_paste_enabled = copy_paste;
    filter->file_xfer_enabled = file_xfer;
    filter->use_client_monitors_config = use_client_monitors_config;
}

void agent_msg_filter_init(AgentMsgFilter *filter,
                           gboolean copy_paste, gboolean file_xfer,
                           gboolean use_client_monitors_config,
                           gboolean discard_all)
{
    memset(filter, 0, sizeof(*filter));
    agent_msg_filter_config(filter, copy_paste, file_xfer,
                            use_client_monitors_config);
    filter->discard_all = discard_all;
}

AgentMsgFilterResult agent_msg_filter_process_data(AgentMsgFilter *filter,
                                                   const uint8_t *data, uint32_t len)
{
    struct VDAgentMessage msg_header;

    if (len > VD_AGENT_MAX_DATA_SIZE) {
        g_warning("invalid agent message: too large");
        return AGENT_MSG_FILTER_PROTO_ERROR;
    }

    /* Are we expecting more data from a previous message? */
    if (filter->msg_data_to_read) {
data_to_read:
        if (len > filter->msg_data_to_read) {
            g_warning("invalid agent message: data exceeds size from header");
            return AGENT_MSG_FILTER_PROTO_ERROR;
        }
        filter->msg_data_to_read -= len;
        return filter->result;
    }

    if (len < sizeof(msg_header)) {
        g_warning("invalid agent message: incomplete header");
        return AGENT_MSG_FILTER_PROTO_ERROR;
    }
    memcpy(&msg_header, data, sizeof(msg_header));
    msg_header.protocol = GUINT32_FROM_LE(msg_header.protocol);
    msg_header.type = GUINT32_FROM_LE(msg_header.type);
    msg_header.size = GUINT32_FROM_LE(msg_header.size);
    len -= sizeof(msg_header);

    if (msg_header.protocol != VD_AGENT_PROTOCOL) {
        g_warning("invalid agent protocol: %u", msg_header.protocol);
        return AGENT_MSG_FILTER_PROTO_ERROR;
    }

    if (filter->discard_all) {
        filter->result = AGENT_MSG_FILTER_DISCARD;
    } else {
        // default, easier to set once
        filter->result = AGENT_MSG_FILTER_OK;
        switch (msg_header.type) {
        case VD_AGENT_CLIPBOARD:
        case VD_AGENT_CLIPBOARD_GRAB:
        case VD_AGENT_CLIPBOARD_REQUEST:
        case VD_AGENT_CLIPBOARD_RELEASE:
            if (!filter->copy_paste_enabled) {
                filter->result = AGENT_MSG_FILTER_DISCARD;
            }
            break;
        case VD_AGENT_FILE_XFER_START:
        case VD_AGENT_FILE_XFER_STATUS:
        case VD_AGENT_FILE_XFER_DATA:
            if (!filter->file_xfer_enabled) {
                filter->result = AGENT_MSG_FILTER_DISCARD;
            }
            break;
        case VD_AGENT_MONITORS_CONFIG:
            if (filter->use_client_monitors_config) {
                filter->result = AGENT_MSG_FILTER_MONITORS_CONFIG;
            }
            break;
        default:
            break;
        }
    }

    filter->msg_data_to_read = msg_header.size;
    if (filter->msg_data_to_read) {
        goto data_to_read;
    }

    return filter->result;
}
