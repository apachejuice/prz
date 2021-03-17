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
    public enum PrimitiveDataType {
        INT64,
        INT32,
        INT16,
        INT8,
        FLOAT32,
        FLOAT64,
        BOOL,
        CHAR32, 
    }

    public struct PrimitiveValue {
        public PrimitiveData data;
        public PrimitiveDataType type;

        public string to_string () {
            switch (type) {
                case PrimitiveDataType.INT64: return "%j".printf (data.l);
                case PrimitiveDataType.INT32: return "%d".printf (data.i);
                case PrimitiveDataType.INT16: return "%d".printf (data.s);
                case PrimitiveDataType.INT8: return "%d".printf (data.x);
                case PrimitiveDataType.FLOAT32: return "%f".printf (data.f);
                case PrimitiveDataType.FLOAT64: return "%f".printf (data.d);
                case PrimitiveDataType.BOOL: return data.b ? "true" : "false";
                case PrimitiveDataType.CHAR32: return data.c.to_string ();
            }

            return (!) null;
        }
    }

    public class PVM : Object {
        private Code code;
     
        public PVM (Code code) {
            this.code = code;
        }

        public void run () throws VMError {
            resolve ();
            run_main ();
        }

        private void run_main () throws VMError {
            var main_func = get_function ("Main");
            if (main_func == null) {
                throw new VMError.NO_MAIN_METHOD ("No main method found. Please define the main method as 'func Main(args [String]) Int'");
            }

            run_function (main_func);
        }

        private Function? get_function (string name) throws VMError {
            Function f;
            for (int i = 0; i < code.functions.size; i++) {
                if (get_string ((f = code.functions[i]).name_ref) == name) {
                    return f;
                }
            }

            return null;
        }

        private string get_string (uint32 cp_ref) throws VMError {
            cp_has_entry (cp_ref);
            var entry = code.constant_pool.entries[(int) cp_ref];
            if (entry.e_type != Pool.EntryType.UTF_8) {
                throw new VMError.MISSING_CP_REF ("Missing constant pool reference to UTF-8 at 0x%08X", cp_ref);
            }

            return Util.byte_array_to_string (entry.raw_data);
        }

        private void resolve () throws VMError {
            for (int i = 0; i < code.functions.size; i++) {
                check_function (code.functions[i]);
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
                throw new VMError.MISSING_CP_REF ("Unidentified constant pool reference 0x%08X", i);
            }
        }

        private void run_function (Function f) throws VMError {
            var locals = new Stack<PrimitiveValue?> ();
            
            for (int i = 0; i < f.code.size; i++) {
                var args = f.code[i].args;
                stdout.printf ("locals: %s\n", locals_to_string (locals));
                OpCode op;
                switch (op = (OpCode) f.code[i].opcode) {
                    case OpCode.BNO:
                    case OpCode.BYES: {
                        locals.push (new_bool (op == OpCode.BYES));
                        break;
                    }

                    case OpCode.IPUSH: {
                        locals.push (new_i32 ((int32) args[0]));
                        break;
                    }

                    case OpCode.DUP: {
                        locals.push (locals.peek ());
                        break;
                    }

                    case OpCode.IADD:
                    case OpCode.IDIV: 
                    case OpCode.IMUL: 
                    case OpCode.IMOD:
                    case OpCode.ISUB: {
                        require_integer_maxsize (32, locals.peek ());
                        var first = locals.pop ();
                        var second = locals.pop ();
                        locals.push (i32_arithmetic (first.data.i, second.data.i, op));
                        break;
                    }

                    case OpCode.POP: {
                        locals.pop ();
                        break;
                    }

                    case OpCode.ROT: {
                        var first = locals.pop ();
                        var second = locals.pop ();
                        locals.push (first);
                        locals.push (second);
                        break;
                    }

                    default: {
                        throw new VMError.UNIMPLEMENTED ("Unimplemented opcode: 0x%02X (%s)", op, op.to_string ());
                    }
                }
            }

            stdout.printf ("locals: %s\n", locals_to_string (locals));
        }

        private PrimitiveValue i32_arithmetic (int32 a, int32 b, OpCode op) throws VMError {
            int32 value;
            switch (op) {
                case OpCode.IADD: value = a + b; break;
                case OpCode.IDIV: value = a / b; break;
                case OpCode.IMOD: value = a % b; break;
                case OpCode.IMUL: value = a * b; break;
                case OpCode.ISUB: value = a - b; break;
                default: throw new VMError.UNIMPLEMENTED ("Opcode %02X (%s) cannot be applied to int32", op, op.to_string ());
            }

            return new_i32 (value);
        }

        private void require_integer_maxsize (uint8 maxsize, PrimitiveValue value) throws VMError {
            if (maxsize == 8) {
                require_type (value, PrimitiveDataType.INT8);
            } else if (maxsize == 16) {
                require_type (value, PrimitiveDataType.INT16);
            } else if (maxsize == 32) {
                require_type (value, PrimitiveDataType.INT32);
            } else if (maxsize == 64) {
                require_type (value, PrimitiveDataType.INT64);
            } else {
                throw new VMError.INTERNAL ("Invalid integer size %d", maxsize);
            }
        }

        private void require_type (PrimitiveValue value, PrimitiveDataType type) throws VMError {
            if (value.type != type) {
                throw new VMError.WRONG_TYPE ("Found incompatible type %s on stack", value.type.to_string ());
            }
        }

        private void require_integer_type (PrimitiveValue value) throws VMError {
            if (!(value.type == PrimitiveDataType.INT8 || value.type == PrimitiveDataType.INT16 || value.type == PrimitiveDataType.INT32 || value.type == PrimitiveDataType.INT64)) {
                throw new VMError.WRONG_TYPE ("Found incompatible type %s on stack", value.type.to_string ());
            } 
        }

        private PrimitiveValue new_i32 (int32 value = 0) {
            return { data: { i: value }, type: PrimitiveDataType.INT32 };
        }

        private PrimitiveValue new_bool (bool value = false) {
            // Vala refuses to compile if we use the same style as the function above???
            var result = PrimitiveValue ();
            result.data.b = value;
            result.type = PrimitiveDataType.BOOL;
            return result;
        }

        private string locals_to_string (Stack<PrimitiveValue?> locals) {
            if (locals.is_empty) return "[]";
            var result = new StringBuilder ("[");
            for (int i = 0; i < locals.size - 1; i++) {
                result.append_printf ("%s, ", locals[i].to_string ());
            }

            return result.str + "%s]".printf (locals.last ().to_string ());
        }
    }
}