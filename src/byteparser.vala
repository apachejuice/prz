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
     * The ByteParser builds a {@link Code} out of input bytes.
     */
    public class ByteParser : Object {
        public const int64 MAGIC_VALUE = 0xBEEFCAFE;
        public const int MIN_POOL_ENTRIES_COUNT = 0x01;
        public const uint8 CONSTANT_POOL_BEGIN = 0xCB;
        public const uint8 CONSTANT_POOL_END = 0xBC;
        public const uint8 CONSTANT_POOL_ENTRY = 0xE0;
        public const uint8 CONSTANT_POOL_TYPE_LINK = 0x87;
        public const uint8 CONSTANT_POOL_TYPE_NUM = 0x88;
        public const uint8 CONSTANT_POOL_TYPE_TEXT = 0x89;
        public const uint8 VERSION_MARKER = 0xEE;
        public const uint8 SRC_NAME_MARKER = 0x50;

        public const uint8 VERSION_0_1 = 0x10;
        public const uint8[] VALID_VERSIONS = {VERSION_0_1};

        private ByteScanner scanner;

        private enum IntegerType {
            BYTE,
            SHORT,
            INT,
        }

        private uint8[]? read_file (string path) throws Error {
            var f = File.new_for_path (path);
            var size = f.query_info ("standard::size", 0).get_size ();

            try {
                var s = f.read ();
                uint8[] buf = new uint8[size];
                size_t read;
                s.read_all (buf, out read);
                debug ("Read file %s, size %zu", path, read);
                s.close ();
                return buf;
            } catch (FormatError e) {
                stdout.printf ("I/O error while reading file %s: %s\n", path, e.message);
                Process.exit (21);
            } catch (Error e) {
                stdout.printf ("Error while reading file %s: %s\n", path, e.message);
                Process.exit (21);
            }
        }

        public Code parse_bytes (string path) throws Error {
            var bytes = read_file (path);
            scanner = new ByteScanner (bytes);

            // Verify the first 4 bytes as 0xBEEFCAFE
            uint32 magic;
            if ((magic = scanner.read_int ()) != MAGIC_VALUE) {
                throw new FormatError.INVALID_MAGIC_BYTES ("Invalid magic value 0x%X".printf (magic));
            }

            var version = get_version ();
            if (!(version in VALID_VERSIONS)) {
                throw new FormatError.SEMANTIC ("Invalid version number %d, valid %s", version, get_valid_versions ());
            } else {
                debug ("Bytecode version: %d (0x%X, Pretzel %s)", version, version, get_version_string (version));
            }

            var source_name = get_source_name ();
            debug ("Source filename: %s", source_name);
            var pool = build_constant_pool ();

            return new Code (pool, version, source_name);
        }

        private string get_source_name () throws FormatError {
            accept (SRC_NAME_MARKER);
            var len = read (IntegerType.INT);
            var data = new uint8[len];

            for (uint32 i = 0; i < len; i++) {
                data[i] = (uint8) read (IntegerType.BYTE);
            }

            return Util.byte_array_to_string (data);
        }

        private string get_version_string (uint8 version) {
            switch (version) {
                case 16: return "0.1";
                default: return (!) null;
            }
        }

        private string get_valid_versions () {
            var result = new StringBuilder ();
            result.append ("version");
            if (VALID_VERSIONS.length > 1) {
                result.append ("s are ");
            } else {
                return result.str + " is %d".printf (VALID_VERSIONS[0]);
            }

            if (VALID_VERSIONS.length == 2) {
                return result.str + "%d and %d".printf (VALID_VERSIONS[0], VALID_VERSIONS[1]);
            } else {
                var i = 0;
                for (; i < VALID_VERSIONS.length - 2; i++) {
                    result.append_printf ("%d, ", VALID_VERSIONS[i]);
                }

                result.append_printf ("%d and %d", VALID_VERSIONS[i], VALID_VERSIONS[i + 1]);
                return result.str;
            }
        }

        private uint8 get_version () throws FormatError {
            accept (VERSION_MARKER);
            return scanner.read_byte ();
        }

        private Pool build_constant_pool () throws FormatError {
            var entries = new Gee.ArrayList<Pool.Entry> ();
            accept (CONSTANT_POOL_BEGIN);
            var count = 0;

            while (peek (IntegerType.BYTE) == CONSTANT_POOL_ENTRY) {
                Pool.Entry? e = null;
                scanner.read_byte ();
                var len = read (IntegerType.INT);
                var type = read (IntegerType.BYTE);

                if (type == CONSTANT_POOL_TYPE_TEXT) {
                    var data = new uint8[len];
                    for (uint32 i = 0; i < len; i++) {
                        data[i] = (uint8) read (IntegerType.BYTE);
                    }

                    e = new Pool.Entry (data, count);
                } else if (type == CONSTANT_POOL_TYPE_NUM) {
                    uint32 num;
                    if (len == 1) {
                        num = read (IntegerType.BYTE);
                    } else if (len == 2) {
                        num = read (IntegerType.SHORT);
                    } else if (len == 4) {
                        num = read (IntegerType.INT);
                    } else {
                        throw new FormatError.SEMANTIC ("Invalid length 0x%X on integer type", len);
                    }

                    e = new Pool.Entry.number (num, count);
                } else if (type == CONSTANT_POOL_TYPE_LINK) {
                    var dest = read (IntegerType.INT);
                    e = new Pool.Entry.link (dest);
                } else {
                    throw new FormatError.INVALID ("Invalid constant pool entry type 0x%X (Did you forget the constant pool end byte 0xBC?)", type);
                }

                count++;
                entries.add (e);
            }

            accept (CONSTANT_POOL_END);

            if (count < MIN_POOL_ENTRIES_COUNT) {
                throw new FormatError.SEMANTIC ("Invalid constant pool length %d", entries.size);
            }

            foreach (var e in entries) {
                debug ("Constant pool: " + e.to_string ());
            }

            debug ("Created constant pool, length %d", entries.size);
            return new Pool (entries);
        }

        private void accept (uint32 num) throws FormatError, FormatError {
            uint32 a;

            if (num < 256) {
                a = scanner.read_byte ();
            } else if (num < 65536) {
                a = scanner.read_short ();
            } else {
                a = scanner.read_int ();
            }

            if (num != a) {
                throw new FormatError.INVALID ("expected 0x%X, got 0x%X", num, a);
            }
        }

        private uint32 read (IntegerType type) throws FormatError {
            switch (type) {
                case IntegerType.BYTE:  return scanner.read_byte ();
                case IntegerType.SHORT: return scanner.read_short ();
                case IntegerType.INT:   return scanner.read_int ();
           }

           return 0;
        }

        private uint32 peek (IntegerType type) throws FormatError {
            switch (type) {
                case IntegerType.BYTE:  return scanner.peek_byte ();
                case IntegerType.SHORT: return scanner.peek_short ();
                case IntegerType.INT:   return scanner.peek_int ();
            }

            return 0;
        }
    }
}
