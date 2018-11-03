package org.ballerinalang.net.http.nativeimpl.cookies;

import org.ballerinalang.bre.Context;
import org.ballerinalang.bre.bvm.BlockingNativeCallableUnit;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.model.values.BMap;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.Receiver;

import java.util.ArrayList;

import static org.ballerinalang.mime.util.MimeConstants.FIRST_PARAMETER_INDEX;
import static org.ballerinalang.mime.util.MimeConstants.SECOND_PARAMETER_INDEX;
import static org.ballerinalang.net.http.HttpConstants.SERVER_COOKIES;

@BallerinaFunction(
        orgName = "ballerina", packageName = "http",
        functionName = "addCookie",
        receiver = @Receiver(type = TypeKind.OBJECT, structType = "CookieJar", structPackage = "ballerina/http"),
        isPublic = true
)
public class AddCookie extends BlockingNativeCallableUnit {

    @Override
    public void execute(Context context) {
        BMap<String, BValue> cookieJar = (BMap<String, BValue>) context.getRefArgument(FIRST_PARAMETER_INDEX);
        BMap<String, BValue> cookieToBeAdded = (BMap<String, BValue>) context.getRefArgument(SECOND_PARAMETER_INDEX);

        if (cookieJar.getNativeData(SERVER_COOKIES) != null) {
            ArrayList<BMap<String, BValue>> cookies = (ArrayList<BMap<String, BValue>>) cookieJar.getNativeData(
                    SERVER_COOKIES);
            cookies.add(cookieToBeAdded);
        } else {
            //No Cookies in Jar
            ArrayList<BMap<String, BValue>> cookies = new ArrayList<>();
            cookies.add(cookieToBeAdded);
            cookieJar.addNativeData(SERVER_COOKIES, cookies);
        }
    }
}
