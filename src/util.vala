/* util.vala
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
    [Compact] // instances aren't created, no need for ref counting
    public class Util {
        private Util () {  }
        public static Gee.Map<uint, T> list_to_map<T> (Gee.List<T> list) {
            var result = new Gee.HashMap<uint, T> ();
            for (uint i = 0; i < (uint) list.size; i++) result[i] = list[(int) i];
            return result;
        }

        public static uint32 byte_array_to_number (uint8[] arr) {
            var bp = new ByteScanner (arr);

            if (arr.length == 1) {
                return bp.read_byte ();
            } else if (arr.length == 2) {
                return bp.read_short ();
            } else if (arr.length == 4) {
                return bp.read_int ();
            } else {
                stdout.printf ("Cannot read number from %d bytes\n", arr.length);
                Process.exit (1);
            }
        }

        public static string byte_array_to_string (uint8[] arr) {
            var result = new StringBuilder ();
            foreach (var b in arr) {
                result.append_printf ("%c", b);
            }

            return result.str;
        }
    }
}
