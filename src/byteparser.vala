/* byteparser.vala
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
     * This class provides methods and
     * routines for parsing raw bytecode.
     */
    public class ByteParser : Object {
        /**
         * The index this ByteParser is currently at.
         */
        private int idx = 0;

        /**
         * The bytes this ByteParser parses.
         */
        private uint8[] bytes;

        /**
         * Create a new ByteParser used to parse ``bytes.``
         *
         * @param bytes The bytes this ByteParser parsers.
         * @return A new ByteParser for the specified bytes.
         */
        public ByteParser (uint8[] bytes) {
            this.bytes = bytes;
        }

        /**
         * Reads a single 8-bit integer from ``bytes.``
         *
         * @return The next byte as an {@link uint8}.
         */
        public uint8 read_byte () requires (this.bytes.length - idx >= 1) {
            return this.bytes[idx++];
        }

        /**
         * Reads a single 16-bit integer from ``bytes.``
         *
         * @return The next 2 bytes as a {@link uint16}.
         */
        public uint16 read_short () requires (this.bytes.length - idx >= 2) {
            return
                (((uint16) this.bytes[idx++]) << 8)
                + ((uint16) this.bytes[idx++]);
        }

        /**
         * Reads a single 32-bit integer from ``bytes.``
         *
         * @return The next 4 bytes as a {@link uint32}.
         */
        public uint32 read_int () requires (this.bytes.length - idx >= 4) {
            return
                  (((uint32) this.bytes[idx++]) << 24)
                + (((uint32) this.bytes[idx++]) << 16)
                + (((uint32) this.bytes[idx++]) <<  8)
                + ((uint32) this.bytes[idx++]);
        }

        /**
         * Peeks a single 8-bit integer from ``bytes.``
         *
         * @return The next byte as an {@link uint8}.
         */
        public uint8 peek_byte () requires (this.bytes.length - idx >= 1) {
            return this.bytes[idx];
        }

        /**
         * Peeks a single 16-bit integer from ``bytes.``
         *
         * @return The next 2 bytes as a {@link uint16}.
         */
        public uint16 peek_short () requires (this.bytes.length - idx >= 2) {
            return
                (((uint16) this.bytes[idx]) << 8)
                + ((uint16) this.bytes[idx + 1]);
        }

        /**
         * Peeks a single 32-bit integer from ``bytes.``
         *
         * @return The next 4 bytes as a {@link uint32}.
         */
        public uint32 peek_int () requires (this.bytes.length - idx >= 4) {
            return
                  (((uint32) this.bytes[idx]) << 24)
                + (((uint32) this.bytes[idx + 1]) << 16)
                + (((uint32) this.bytes[idx + 2]) <<  8)
                + ((uint32) this.bytes[idx + 3]);
        }

        public bool has_next {
            get {
                return idx < this.bytes.length;
            }
        }
    }
}
