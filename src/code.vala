/* code.vala
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
    public class Code : Object {
        public Pool constant_pool { get; private set; }
        public uint8 bytecode_version { get; private set; }
        public string source_name { get; private set; }

        public Code (Pool constant_pool, uint8 bytecode_version,
                     string source_name) {
            this.constant_pool = constant_pool;
            this.bytecode_version = bytecode_version;
            this.source_name = source_name;
        }
    }
}
