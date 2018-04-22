package org.ballerinalang.net.http.nativeimpl.request;

import org.ballerinalang.bre.Context;
import org.ballerinalang.bre.bvm.BlockingNativeCallableUnit;
import org.ballerinalang.mime.util.EntityBodyHandler;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.model.values.BStruct;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.Receiver;
import org.ballerinalang.natives.annotations.ReturnType;
import org.ballerinalang.net.http.HttpUtil;

import static org.ballerinalang.mime.util.Constants.FIRST_PARAMETER_INDEX;

@BallerinaFunction(
        orgName = "ballerina", packageName = "http",
        functionName = "createNewEntity",
        receiver = @Receiver(type = TypeKind.STRUCT, structType = "Request",
                structPackage = "ballerina.http"),
        args = {@Argument(name = "request", type = TypeKind.STRUCT)},
        returnType = {@ReturnType(type = TypeKind.STRUCT)},
        isPublic = false
)
public class CreateNewEntity extends BlockingNativeCallableUnit {
    @Override
    public void execute(Context context) {
        BStruct requestObject = (BStruct) context.getRefArgument(FIRST_PARAMETER_INDEX);
        context.setReturnValues(HttpUtil.createNewEntity(context, requestObject));
    }
}
