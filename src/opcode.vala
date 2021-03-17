/* opcode.vala
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
    public enum OpCode {
        /* Stack controls */
        DYNSTACK = 0x01,
        MAXSTACK = 0x02,

        /* Miscellaneous */
        POP = 0x09,
        DUP = 0x10,
        ROT = 0x11,

        /* Integer operations */
        IPUSH = 0x03,
        IADD = 0x04,
        ISUB = 0x05,
        IDIV = 0x06,
        IMUL = 0x07,
        IMOD = 0x08,
         
        /* Boolean stuff */
        BYES = 0x12,
        BNO = 0x13,
        BNEG = 0x14,
    }
}