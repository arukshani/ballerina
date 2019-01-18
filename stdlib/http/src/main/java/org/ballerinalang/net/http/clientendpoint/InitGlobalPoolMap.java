package org.ballerinalang.net.http.clientendpoint;

import org.ballerinalang.bre.Context;
import org.ballerinalang.bre.bvm.BlockingNativeCallableUnit;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaFunction;

@BallerinaFunction(orgName = "ballerina", packageName = "http",
        functionName = "initGlobalPoolMap", args = { @Argument(name = "client", type = TypeKind.OBJECT,
                                                        structType = "Client") },
        isPublic = true)
    public class InitGlobalPoolMap extends BlockingNativeCallableUnit {

    @Override public void execute(Context context) {

    }
}
