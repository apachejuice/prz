/* formaterror.vala
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
    public class Stack<T> : Gee.ArrayList<T> {
        public T push (T e) {
            add (e);
            return e;
        }

        public T pop () throws VMError {
            if (is_empty) {
                throw new VMError.EMPTY_STACK ("Attempted to pop from empty stack");
            }

            var result = last ();
            remove_at (size - 1);
            return result;
        }

        public T peek () throws VMError {
            if (is_empty) {
                throw new VMError.EMPTY_STACK ("Attempted to peek from empty stack");
            }
            return last ();
        }
    }
}