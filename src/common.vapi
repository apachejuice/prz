/* bridge.vapi
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
    [CCode (cheader_filename = "primitivedata.h", cname = "PrimitiveData")]
    public struct PrimitiveData {
        [CCode (cname = "l")]
        int64 l;
        [CCode (cname = "i")]
        int32 i;
        [CCode (cname = "s")]
        int16 s;
        [CCode (cname = "x")]
        int8 x;
        [CCode (cname = "f")]
        float f;
        [CCode (cname = "d")]
        double d;
        [CCode (cname = "b")]
        bool b;
        [CCode (cname = "c")]
        unichar c;
    }    
}