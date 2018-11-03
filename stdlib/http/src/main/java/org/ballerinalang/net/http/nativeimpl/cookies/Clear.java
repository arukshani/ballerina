package org.ballerinalang.net.http.nativeimpl.cookies;

import org.ballerinalang.bre.Context;
import org.ballerinalang.bre.bvm.BlockingNativeCallableUnit;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.model.values.BMap;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.Receiver;

import static org.ballerinalang.mime.util.MimeConstants.FIRST_PARAMETER_INDEX;
import static org.ballerinalang.net.http.HttpConstants.SERVER_COOKIES;

@BallerinaFunction(
        orgName = "ballerina", packageName = "http",
        functionName = "clear",
        receiver = @Receiver(type = TypeKind.OBJECT, structType = "CookieJar", structPackage = "ballerina/http"),
        isPublic = true
)
public class Clear extends BlockingNativeCallableUnit {

    @Override
    public void execute(Context context) {
        BMap<String, BValue> cookieJar = (BMap<String, BValue>) context.getRefArgument(FIRST_PARAMETER_INDEX);
        cookieJar.addNativeData(SERVER_COOKIES, null);
    }
}
