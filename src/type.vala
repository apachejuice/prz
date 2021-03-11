/*
 * type.vala
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
 * 
 */

namespace Prz {
    public enum TypeKind {
        PRIMITIVE_INT = 'I',
        PRIMITIVE_LONG = 'L',
        PRIMITIVE_SHORT = 'S',
        PRIMITIVE_BYTE = 'X',
        PRIMITIVE_CHAR = 'C',
        PRIMITIVE_FLOAT = 'F',
        PRIMITIVE_DOUBLE = 'D',
        PRIMITIVE_BOOL = 'B',

        REFERENCE;

        public static TypeKind[] get_all_values () {
            return new TypeKind[] {
                PRIMITIVE_INT, PRIMITIVE_LONG,
                PRIMITIVE_SHORT, PRIMITIVE_BYTE,
                PRIMITIVE_CHAR, PRIMITIVE_FLOAT,
                PRIMITIVE_DOUBLE, PRIMITIVE_BOOL,
                REFERENCE,
            };
        }

        public static TypeKind? get_for_char (char ch) {
            foreach (var value in get_all_values ()) {
                if (value == ch) {
                    return value;
                }
            }

            return null;
        }
    }

    public abstract class AbstractType : Object {
        // Vala gets mad at us during runtime if we use this as a property
        public TypeKind get_type_kind () {
            return _kind;
        }

        private TypeKind _kind;
        public bool is_primitive { get; protected set; }
        public uint8 array_depth { get; protected set; }
        public string signature { get; protected set; }

        protected AbstractType (TypeKind kind, bool is_primitive, uint8 array_depth, string signature) {
            this._kind = kind;
            this.is_primitive = is_primitive;
            this.array_depth = array_depth;
            this.signature = (is_primitive ? "#" : "&") + signature + Util.repeat ("]", array_depth);
        }

        public bool equals (AbstractType other) {
            return this.signature == other.signature;
        } 

        public static AbstractType parse (string sig) throws FormatError {
            // sig.length > 1
            if (sig.length <= 1) {
                throw new FormatError.SEMANTIC ("Signature length too short: %d", sig.length);
            }

            if (sig.has_prefix ("#")) {
                if (sig[1] == ']') {
                    throw new FormatError.SEMANTIC ("Missing type in primitive array declaration");
                } else if (Util.char_count (sig, ']') > uint8.MAX) {
                    throw new FormatError.SEMANTIC ("Exceeded maximum array depth: %d (%u)", uint8.MAX, Util.char_count (sig, ']'));
                }

                // We can unsafely cast since we already verified there cannot be more than 255 ]'s.
                return new PrimitiveType (sig[1], (uint8) Util.char_count (sig, ']'));
            } else if (sig.has_prefix ("&")) {
                var arrdepth = Util.char_count (sig, ']');
                var _sig = sig.replace ("]", "");
                var type = _sig[1:_sig.length];
                var segments = new string[uint8.MAX];
                var parts = type.split ("/");
                if (parts.length - 1 >= uint8.MAX) {
                    throw new FormatError.SEMANTIC ("multi-part class name too long");
                }

                var current = new StringBuilder ();
                for (var i = 0; i < parts.length; i++) {
                    for (var n = 0; n < parts[i].length; n++) {
                        current.append (parts[i][n].to_string ());
                    }

                    segments[i] = current.str;
                    current = new StringBuilder ();
                }

                return new ReferenceType (type, (uint8) arrdepth);
            } else {
                throw new FormatError.SEMANTIC ("Invalid type start character %c".printf (sig[0]));
            }
        }
    }

    public class PrimitiveType : AbstractType {
        public PrimitiveType (char s, uint8 arr_depth = 0) {
            base (TypeKind.get_for_char (s), true, arr_depth, "%c".printf (s));
        }
    }

    public class ReferenceType : AbstractType {
        public ReferenceType (string type, uint8 arr_depth = 0) {
            base (TypeKind.REFERENCE, false, arr_depth, type);
        }
    }
}