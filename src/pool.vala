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
        public enum EntryType {
            UTF_8,
            NUMBER,
            LINK,
        }

        /**
         * A single entry in the {@link Pool} is a piece
         * of data contained in it.
         */
        public class Entry : Object {
            /**
             * Can this Entry be a number constant?
             */
            public bool can_be_number { get { return len in new size_t[] {1, 2, 4}; } }

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
             * Is this Entry a link to another entry?
             * This is done on duplicate entries for optimization.
             */
            public bool is_link { get; private set; default = false; }

            public EntryType e_type { get; private set; }

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
                this.e_type = EntryType.UTF_8;
            }

            public Entry.number (uint32 num, uint index) {
                uint8[] arr;

                if (num < 256) {
                    arr = {(uint8) num};
                } else if (num < 65535) {
                    arr = new uint8[] {
                        (uint8)(num & 0xff),
                        (uint8)((num >> 8) & 0xff),
                    };
                } else {
                    arr = new uint8[] {
                        (uint8)((num >> 24) & 0xff),
                        (uint8)((num >> 16) & 0xff),
                        (uint8)((num >> 8) & 0xff),
                        (uint8)((num >> 0) & 0xff),
                    };
                }

                this (arr, index);
                this.e_type = EntryType.NUMBER;
            }

            public Entry.link (uint32 dest) {
                this ({}, dest);
                this.e_type = EntryType.LINK;
            }

            /**
             * Returns ``true``, if this Entry is content-equivalent
             * to ``other`` (e.g. can it be used as a link.)
             */
            public bool equals (Entry other) {
                return this.len == other.len
                    && this.raw_data == other.raw_data;
            }

            public string to_string () {
                var result = new StringBuilder ();
                result.append (@"Entry[len=$len index=$index can_be_number=$can_be_number value={");
                if (raw_data.length <= 10) {
                    for (var i = 0; i < raw_data.length - 1; i++) {
                        result.append ("0x%02X, ".printf (raw_data[i]));
                    }

                    result.append ("0x%02X}".printf (raw_data[raw_data.length - 1]));
                } else {
                    var len = raw_data.length;
                    result.append ("0x%02X, 0x%02X, 0x%02X ... 0x%02X, 0x%02X, 0x%02X}".printf (
                        raw_data[0], raw_data[1], raw_data[2],
                        raw_data[len - 3], raw_data[len - 2], raw_data[len - 1]
                    ));
                }

                if (can_be_number) {
                    result.append (@" as_number=$(Util.byte_array_to_number (raw_data))]");
                } else {
                    result.append (@" as_string='$(Util.byte_array_to_string (raw_data))']");
                }

                return result.str;
            }
        }

        /**
         * The raw data this Pool was created from.
         */
        public uint8[] raw_data { get; private set; }

        /**
         * The {@link Entry}es in this Pool.
         */
        public Gee.List<Entry> entries { get; private set; }

        /**
         * Create a Pool from a list of {@link Entry}es.
         *
         * @param entries The entries this Pool consists of.
         * @return A new Pool object containg the specified {@link Entry}es.
         */
        public Pool (Gee.List<Entry> entries) {
            this.entries = drop (entries);
        }

        private Gee.List<Entry> drop (Gee.Collection<Entry> entries) {
            var result = new Gee.ArrayList<Entry> ();
            foreach (var e in entries) {
                if (!(e in result)) {
                    result.add (e);
                }
            }

            return result;
        }

        public void add_entry (Entry e) {
            this.entries.add (e);
        }

        public new Entry get (uint index) requires (index >= 0) {
            var entry = this.entries[(int) index];
            if (entry.is_link) {
                return get (entry.index);
            } else {
                return entry;
            }
        }
    }
}
