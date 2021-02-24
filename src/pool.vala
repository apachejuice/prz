/* pool.vala
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
    /**
     * A Pool object contains all the raw data extracted
     * from the bytecode, such as string literals, integer constants
     * and other types of immutable data.
     */
    public class Pool : Object {
        /**
         * A single entry in the {@link Pool} is a piece
         * of data contained in it.
         */
        public class Entry : Object {
            /**
             * Can this Entry be a number constant?
             */
            public bool can_be_number { get { return len <= 4; } }

            /**
             * The raw bytes this Entry consists of.
             */
            public uint8[] raw_data { get; private set; }

            /**
             * The amount of bytes in this Entry;
             */
            public size_t len { get { return raw_data.length; } }

            /**
             * The 0-based index of this Entry in the pool.
             */
            public uint index { get; private set; }

            /**
             * Create a new Entry from the bytes in ``data.``
             *
             * @param data The data in this Entry.
             * @param index The index of this Entry in the pool.
             * @return A new Entry created from ``data.``
             */
            public Entry (uint8[] data, uint index) {
                this.raw_data = data;
                this.index = index;
            }

            /**
             * Returns ``true``, if this Entry is content-equivalent
             * to ``other`` (e.g. can it be used as a link.)
             */
            public bool equals (Entry other) {
                return this.len == other.len
                    && this.raw_data == other.raw_data;
            }
        }

        /**
         * The raw data this Pool was created from.
         */
        public uint8[] raw_data { get; private set; }

        /**
         * The {@link Entry}es in this Pool.
         */
        public Gee.Map<uint, Entry> entries { get; private set; }

        /**
         * Create a Pool from a list of {@link Entry}es.
         *
         * @param entries The entries this Pool consists of.
         * @return A new Pool object containg the specified {@link Entry}es.
         */
        public Pool (Gee.List<Entry> entries) {
            this.entries = Util.list_to_map (entries);
        }

        public void add_entry (Entry e) {
            for (var i = 0u; i < entries.size; i++) {
                if (entries[i].equals (e)) {
                    entries[entries.size] = entries[i];
                }
            }
        }
    }
}
