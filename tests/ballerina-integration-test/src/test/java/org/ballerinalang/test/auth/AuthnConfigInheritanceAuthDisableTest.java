/*
 *  Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

package org.ballerinalang.test.auth;

import org.ballerinalang.test.BaseTest;
import org.ballerinalang.test.context.BallerinaTestException;
import org.ballerinalang.test.util.HttpClientRequest;
import org.ballerinalang.test.util.HttpResponse;
import org.testng.Assert;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

/**
 * Test cases for disabling authorization scenarios.
 *
 * @since 0.970.0
 */
@Test(groups = "auth-test")
public class AuthnConfigInheritanceAuthDisableTest extends BaseTest {

    private final int servicePort = 9090;

    @Test(description = "non secured resource test case with no auth headers")
    public void testResourceLevelAuthDisableWithNoAuthHeaders()
            throws Exception {
        HttpResponse response = HttpClientRequest.doGet(serverInstance.getServiceURLHttp(servicePort, "echo/test"));
        Assert.assertNotNull(response);
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
    }

    @Test(description = "non secured resource test case")
    public void testResourceLevelAuthDisable()
            throws Exception {
        Map<String, String> headersMap = new HashMap<>();
        headersMap.put("Authorization", "Basic dGVzdDp0ZXN0MTIz");
        HttpResponse response = HttpClientRequest.doGet(serverInstance.getServiceURLHttp(servicePort, "echo/test"),
                headersMap);
        Assert.assertNotNull(response);
        Assert.assertEquals(response.getResponseCode(), 200, "Response code mismatched");
    }

    @BeforeTest(groups = "auth-test")
    public void start() throws BallerinaTestException {
        String basePath = new File("src" + File.separator + "test" + File.separator + "resources" + File.separator +
                "auth").getAbsolutePath();
        String ballerinaConfPath = basePath + File.separator + "ballerina.conf";
        String[] args = new String[]{"--sourceroot", basePath, "--config", ballerinaConfPath};
        serverInstance.startBallerinaServer("authservices", args);
    }

    @AfterTest(groups = "auth-test")
    public void cleanup() throws Exception {
        serverInstance.removeAllLeechers();
        serverInstance.stopServer();
    }
}
