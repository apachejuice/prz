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


/**
 * The entry point for the VM.
 */
int main (string[] args) {
    // Make sure GLib uses the correct locale
    Intl.setlocale (LocaleCategory.ALL);
    var vm = new Prz.VM ();
    try {
        vm.run (args);
    } catch (Prz.FormatError e) {
        stdout.printf ("An error occurred while validating the file format: %s\n", e.message);
        Process.exit (22);
    } catch (Error e) {
        Prz.ErrorReporter.fatal ((int) e.domain, e.message);
    }

    return vm.code;
}
