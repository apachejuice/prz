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
namespace Prz {
    /**
     * A FormatError is thrown when there is
     * some kind of error in the bytecode.
     */
    public errordomain FormatError {
        /**
         * This error code indicates that the first
         * 4 bytes used to identify a bytecode file
         * were incorrect - they must equal ``0xBEEFCAFE.``
         */
        INVALID_MAGIC_BYTES,

        /**
         * This error code is thrown when an unexpected
         * byte was found in the bytecode.
         */
        INVALID,

        /**
         * This error code is thrown when there is a
         * semantic issue; such as an invalid attribute on
         * some value.
         */
        SEMANTIC,

        /**
         * This error code indicates that a byte was expected but not found.
         */
        EOF,
    }
}
