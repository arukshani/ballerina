package org.ballerinalang.net.http.nativeimpl.cookies;

import org.ballerinalang.bre.Context;
import org.ballerinalang.bre.bvm.BlockingNativeCallableUnit;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.model.values.BMap;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.Receiver;
import org.ballerinalang.natives.annotations.ReturnType;

import java.util.ArrayList;

import static org.ballerinalang.mime.util.MimeConstants.FIRST_PARAMETER_INDEX;
import static org.ballerinalang.net.http.HttpConstants.SERVER_COOKIES;
import static org.ballerinalang.net.http.HttpUtil.getError;
import static org.ballerinalang.net.http.nativeimpl.cookies.Util.getArrayOfCookies;

@BallerinaFunction(
        orgName = "ballerina", packageName = "http",
        functionName = "getCookies",
        receiver = @Receiver(type = TypeKind.OBJECT, structType = "CookieJar", structPackage = "ballerina/http"),
        returnType = {@ReturnType(type = TypeKind.ARRAY), @ReturnType(type = TypeKind.RECORD)},
        isPublic = true
)
public class GetCookies extends BlockingNativeCallableUnit {

    @Override
    public void execute(Context context) {
        BMap<String, BValue> cookieJar = (BMap<String, BValue>) context.getRefArgument(FIRST_PARAMETER_INDEX);
        if (cookieJar.getNativeData(SERVER_COOKIES) != null) {
            ArrayList<BMap<String, BValue>> cookies = (ArrayList<BMap<String, BValue>>) cookieJar.getNativeData(
                    SERVER_COOKIES);
            context.setReturnValues(getArrayOfCookies(cookies));
        } else {
            context.setReturnValues(getError(context, "Cookie Jar is empty"));
        }
    }
}
