// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerinax/java;

# Prints `any` or `error` value(s) to the STDOUT.
# + values - The value(s) to be printed.
public function print((any|error)... values) = @java:Method {
    name: "print",
    class: "org.ballerinalang.stdlib.io.nativeimpl.PrintUtils"
} external;

# Prints `any` or `error` value(s) to the STDOUT followed by a new line.
# + values - The value(s) to be printed.
public function println((any|error)... values) = @java:Method {
    name: "println",
    class: "org.ballerinalang.stdlib.io.nativeimpl.PrintUtils"
} external;

# Returns a formatted string using the specified format string and arguments. Following format specifiers are allowed.
#
# b - boolean
#
# B - boolean (ALL_CAPS)
#
# d - int
#
# f - float
#
# x - hex
#
# X - HEX (ALL_CAPS)
#
# s - string (This specifier is applicable for any of the supported types in Ballerina.
#             These values will be converted to their string representation.)
#
# + format - A format string
# + args   - Arguments referenced by the format specifiers in the format string.
# + return - Formatted string
public function sprintf(string format, (any|error)... args) returns string {
    return <string>java:toString(sprintfExtern(java:fromString(format), ...args));
}

function sprintfExtern(handle format, (any|error)... args) returns handle = @java:Method {
    name: "sprintf",
    class: "org.ballerinalang.stdlib.io.nativeimpl.Sprintf"
} external;
