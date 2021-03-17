/* main.vala
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

namespace Prz {
    public class Main : Object {
        private static bool version = false;

        private const OptionEntry[] entries = {
            { "version", 'v', 0, OptionArg.NONE, ref version, "Show the version and exit", null },
            { null },
        };

       /**
        * The entry point for the VM.
        */
        public static int main (string[] args) {
            // Make sure GLib uses the correct locale
            Intl.setlocale (LocaleCategory.ALL);

            // parse options
            var ctx = new OptionContext ();
            ctx.add_main_entries (entries, null);
            try {
                ctx.parse (ref args);
            } catch (OptionError e) {
                stderr.printf ("%s\n", e.message);
                Process.exit (1);
            }

            run_options ();

            var parser = new Prz.ByteParser ();
            try {
                var code = parser.parse_bytes (args[1]);
                var vm = new PVM (code);
                vm.run ();
            } catch (Prz.FormatError e) {
                stdout.printf ("An error occurred while validating the file format: %s\n", e.message);
                Process.exit (1);
            } catch (Prz.VMError e) {
                stdout.printf ("An error occurred running the VM: %s\n", e.message);
                Process.exit (1);
            }

            return 0;
        }

        private static void run_options () {
            if (version) {
                stdout.printf ("%s %s", Config.PKGNAME, Config.PKGVER);
                Process.exit (0);
            }
        }
    }
}