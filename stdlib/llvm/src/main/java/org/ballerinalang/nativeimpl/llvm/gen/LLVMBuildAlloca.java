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

package org.ballerinalang.nativeimpl.llvm.gen;

import org.ballerinalang.jvm.scheduling.Strand;
import org.ballerinalang.jvm.types.BPackage;
import org.ballerinalang.jvm.values.MapValue;
import org.ballerinalang.nativeimpl.llvm.FFIUtil;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.ReturnType;
import org.bytedeco.javacpp.LLVM;
import org.bytedeco.javacpp.LLVM.LLVMValueRef;

import static org.ballerinalang.model.types.TypeKind.RECORD;
import static org.ballerinalang.model.types.TypeKind.STRING;

/**
 * Auto generated class.
 *
 * @since 1.0.3
 */
@BallerinaFunction(
        orgName = "ballerina", packageName = "llvm",
        functionName = "llvmBuildAlloca",
        args = {
                @Argument(name = "arg0", type = RECORD, structType = "LLVMBuilderRef"),
                @Argument(name = "ty", type = RECORD, structType = "LLVMTypeRef"),
                @Argument(name = "name", type = STRING),
        },
        returnType = {
                @ReturnType(type = RECORD, structType = "LLVMValueRef", structPackage = "ballerina/llvm"),
        }
)
public class LLVMBuildAlloca {

    public static MapValue<String, Object> llvmBuildAlloca(Strand strand, MapValue<String, Object> arg0,
                                                           MapValue<String, Object> ty, String name) {

        LLVM.LLVMBuilderRef arg0Ref = (LLVM.LLVMBuilderRef) FFIUtil.getRecodeArgumentNative(arg0);
        LLVM.LLVMTypeRef tyRef = (LLVM.LLVMTypeRef) FFIUtil.getRecodeArgumentNative(ty);
        LLVMValueRef returnValue = LLVM.LLVMBuildAlloca(arg0Ref, tyRef, name);
        MapValue<String, Object> returnWrapperRecord = FFIUtil.newRecord(new BPackage("ballerina",
                "llvm"), "LLVMValueRef");
        FFIUtil.addNativeToRecode(returnValue, returnWrapperRecord);
        return returnWrapperRecord;
    }
}
