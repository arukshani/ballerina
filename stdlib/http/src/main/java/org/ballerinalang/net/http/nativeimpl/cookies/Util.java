package org.ballerinalang.net.http.nativeimpl.cookies;

import org.ballerinalang.model.types.BStructureType;
import org.ballerinalang.model.values.BMap;
import org.ballerinalang.model.values.BRefValueArray;
import org.ballerinalang.model.values.BValue;

import java.util.ArrayList;

/**
 * Created by rukshani on 11/3/18.
 */
public class Util {
    static BRefValueArray getArrayOfCookies(ArrayList<BMap<String, BValue>> cookies) {
        BStructureType typeOfCookie = (BStructureType) cookies.get(0).getType();
        BMap<String, BValue>[] result = cookies.toArray(new BMap[cookies.size()]);
        return new BRefValueArray(result, typeOfCookie);
    }
}
