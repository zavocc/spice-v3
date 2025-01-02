/* -*- Mode: C; c-basic-offset: 4; indent-tabs-mode: nil -*- */
/*
   Copyright (C) 2018 Red Hat, Inc.

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
*/
#ifndef TEST_WIN_ALARM_H
#define TEST_WIN_ALARM_H

#include <spice/macros.h>

SPICE_BEGIN_DECLS

#ifdef _WIN32
void test_alarm(unsigned int timeout);
#define alarm test_alarm
#endif

SPICE_END_DECLS

#endif // TEST_WIN_ALARM_H
