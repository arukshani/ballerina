package org.ballerinalang.net.http.nativeimpl.cookies;

import org.ballerinalang.bre.Context;
import org.ballerinalang.bre.bvm.BlockingNativeCallableUnit;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.Receiver;
import org.ballerinalang.natives.annotations.ReturnType;

@BallerinaFunction(
        orgName = "ballerina", packageName = "http",
        functionName = "getCookies",
        receiver = @Receiver(type = TypeKind.OBJECT, structType = "CookieJar", structPackage = "ballerina/http"),
        returnType = {@ReturnType(type = TypeKind.ARRAY)},
        isPublic = true
)
public class GetCookies extends BlockingNativeCallableUnit {

    @Override
    public void execute(Context context) {

    }
}
