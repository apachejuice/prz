/* vm.vala
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
    public class VM : Object {
        private Code code;
     
        public VM (Code code) {
            this.code = code;
        }

        public void run () throws VMError {
            resolve ();
        }

        private void resolve () throws VMError {
            for (int i = 0; i < code.functions.size; i++) {
                check_function (code.functions[i]);
                run_function (code.functions[i]);
            }
        }

        private void check_function (Function f) throws VMError {
            cp_has_entry (f.name_ref);
            cp_has_entry (f.sig_ref);
        }

        private uint32 get_number (uint32 cp_index) throws VMError, FormatError {
            cp_has_entry (cp_index);
            return Util.byte_array_to_number (code.constant_pool.get (cp_index).raw_data);
        }

        private void cp_has_entry (uint32 i) throws VMError {
            if (code.constant_pool.entries.size - 2 < i) {
                throw new VMError.MISSING_CP_REF ("Unidentified constant pool reference 0x%X", i);
            }
        }

        private void run_function (Function f) throws VMError {
            var locals = new Stack<int32> ();
            
            for (int i = 0; i < f.code.size; i++) {
                var args = f.code[i].args;
                stdout.printf ("locals: %s\n", locals_to_string (locals));
                switch (f.code[i].opcode) {
                    case ByteParser.OP_IPUSH: {
                        locals.push ((int32) args[0]);
                        break;
                    }

                    case ByteParser.OP_DUP: {
                        locals.push (locals.peek ());
                        break;
                    }

                    case ByteParser.OP_IADD: {
                        locals.push (locals.pop() + locals.pop ());
                        break;
                    }

                    case ByteParser.OP_IDIV: {
                        locals.push (locals.pop () / locals.pop ());
                        break;
                    }

                    case ByteParser.OP_IMUL: {
                        locals.push (locals.pop () * locals.pop ());
                        break;
                    }

                    case ByteParser.OP_IMOD: {
                        locals.push (locals.pop () % locals.pop ());
                        break;
                    }

                    case ByteParser.OP_ISUB: {
                        locals.push (locals.pop () - locals.pop ());
                        break;
                    }

                    case ByteParser.OP_POP: {
                        locals.pop ();
                        break;
                    }

                    case ByteParser.OP_ROT: {
                        var first = locals.pop ();
                        var second = locals.pop ();
                        locals.push (first);
                        locals.push (second);
                        break;
                    }

                    default: {
                        throw new VMError.UNIMPLEMENTED ("Unimplemented opcode: 0x%X", f.code[i].opcode);
                    }
                }
            }

            stdout.printf ("locals: %s\n", locals_to_string (locals));
        }

        private string locals_to_string (Stack<uint32> locals) {
            if (locals.is_empty) return "[]";
            var result = new StringBuilder ("[");
            for (int i = 0; i < locals.size - 1; i++) {
                result.append_printf ("%u, ", locals[i]);
            }

            return result.str + "%u]".printf (locals.last ());
        }
    }
}