/* error.vala
 *
 * Copyright 2021 apachejuice <ubuntugeek1904@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
using GLib;

namespace Prz {
    public class ErrorReporter {
        [PrintfFormat]
        public static void fatal (int code, string message, ...) {
            stdout.printf ("The Pretzel Virtual Machine encountered a fatal error and is unable to continue.\n");
            stdout.vprintf (@"Message: $message\n", va_list ());
            stdout.printf ("We have generated a dump of run-time information for you.\n");
            stdout.printf("If the error code is 'ERR_INTERNAL', contact the developers and attach this message and the code that triggered it.\n");
            print_info_table ();
            print_dump ();
            Process.exit (code);
        }

        private static void print_info_table () {
            stdout.printf ("""SYSTEM INFO:
                OS name:        %s
                PID:            %d
            """, Config.PLATFORM, Posix.getpid ());
        }

        private static void print_dump () {
            void*[] buf = new void*[sizeof (void*) * 50];
            Linux.Backtrace.get (buf);
            var syms = Linux.Backtrace.symbols (buf);
            if (syms == null) {
                stdout.printf ("%s\n", "Unable to create backtrace");
            } else {
                stdout.printf ("%s\n", "Stack trace:");
                for (int i = 0; i < syms.length; i++) {
                    if (syms[i] != "[(nil)]") {
                        stdout.printf ("\tat %s (%p)\n", syms[i], &buf[i]);
                    }
                }
            }
        }
    }
}
