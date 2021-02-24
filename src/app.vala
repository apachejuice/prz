/* app.vala
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
    /*
		public unowned string long_name;
		public char short_name;
		public int flags;

		public OptionArg arg;
		public void* arg_data;

		public unowned string description;
		public unowned string? arg_description;
	}
     */
    private const OptionEntry[] options = {
        { "debug", 'd', OptionFlags.NO_ARG, OptionArg.NONE, ref debug, "Emit debug messages from g_debug ()", null },
        { null },
    };

    private bool debug = false;
    /**
     * The App class is an implementation of {@link GLib.Application}.
     * It provides an entry point for the Pretzel Virtual Machine.
     */
    public class App : Application {
        /**
         * Create a new App.
         */
        public App () {
            Object (application_id: "com.pretzel.prz", flags: ApplicationFlags.HANDLES_COMMAND_LINE);
        }

        private void init_cmdline_options () throws OptionError {

        }
    }
}
