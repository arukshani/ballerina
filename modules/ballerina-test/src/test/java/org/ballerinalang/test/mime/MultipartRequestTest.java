/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.ballerinalang.test.mime;

import io.netty.handler.codec.http.multipart.HttpPostRequestEncoder;
import org.ballerinalang.launcher.util.BCompileUtil;
import org.ballerinalang.launcher.util.BServiceUtil;
import org.ballerinalang.launcher.util.CompileResult;
import org.ballerinalang.model.types.BStructType;
import org.ballerinalang.model.values.BJSON;
import org.ballerinalang.model.values.BRefValueArray;
import org.ballerinalang.model.values.BStruct;
import org.ballerinalang.net.http.Constants;
import org.ballerinalang.net.http.HttpUtil;
import org.ballerinalang.test.services.testutils.HTTPTestRequest;
import org.ballerinalang.test.services.testutils.MessageUtils;
import org.ballerinalang.test.services.testutils.Services;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;
import org.wso2.transport.http.netty.message.HTTPCarbonMessage;
import org.wso2.transport.http.netty.message.HttpMessageDataStreamer;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.ArrayList;

import static org.ballerinalang.mime.util.Constants.ENTITY_NAME_INDEX;
import static org.ballerinalang.mime.util.Constants.IS_IN_MEMORY_INDEX;
import static org.ballerinalang.mime.util.Constants.JSON_DATA_INDEX;
import static org.ballerinalang.mime.util.Constants.MEDIA_TYPE;
import static org.ballerinalang.mime.util.Constants.MEDIA_TYPE_INDEX;
import static org.ballerinalang.mime.util.Constants.MESSAGE_ENTITY;
import static org.ballerinalang.mime.util.Constants.MULTIPART_DATA_INDEX;
import static org.ballerinalang.mime.util.Constants.MULTIPART_ENCODER;
import static org.ballerinalang.mime.util.Constants.PRIMARY_TYPE_INDEX;
import static org.ballerinalang.mime.util.Constants.PROTOCOL_PACKAGE_MIME;
import static org.ballerinalang.mime.util.Constants.SUBTYPE_INDEX;
import static org.ballerinalang.mime.util.Constants.UTF_8;

/**
 * Test cases for multipart request handling.
 */
public class MultipartRequestTest {
    private static final Logger LOG = LoggerFactory.getLogger(MultipartRequestTest.class);

    private CompileResult result, serviceResult;
    private final String requestStruct = Constants.REQUEST;
    private final String protocolPackageHttp = Constants.PROTOCOL_PACKAGE_HTTP;
    private final String protocolPackageMime = PROTOCOL_PACKAGE_MIME;
    private final String entityStruct = Constants.ENTITY;
    private final String mediaTypeStruct = MEDIA_TYPE;
    private String sourceFilePath = "test-src/mime/multipart-request.bal";

    @BeforeClass
    public void setup() {
        result = BCompileUtil.compile(sourceFilePath);
        serviceResult = BServiceUtil.setupProgramFile(this, sourceFilePath);
    }

    @Test(description = "Test sending a multipart request with a json body part")
    public void testServiceGetMutliparts() {
        String path = "/test/jsonbodypart";
        BStruct request = BCompileUtil.createAndGetStruct(result.getProgFile(), protocolPackageHttp, requestStruct);
        HTTPTestRequest cMsg = MessageUtils.generateHTTPMessageForMultiparts(path, Constants.HTTP_METHOD_POST);
        HttpUtil.addCarbonMsg(request, cMsg);
        HttpUtil.setHeaderValueStructType(
                BCompileUtil.createAndGetStruct(result.getProgFile(), protocolPackageMime, entityStruct));

        BStruct entity = BCompileUtil.createAndGetStruct(result.getProgFile(), protocolPackageMime, entityStruct);
        BStruct mediaType = BCompileUtil.createAndGetStruct(result.getProgFile(), protocolPackageMime, mediaTypeStruct);
        mediaType.setStringField(PRIMARY_TYPE_INDEX, "multipart");
        mediaType.setStringField(SUBTYPE_INDEX, "form-data");

        BStruct bodyPart = BCompileUtil.createAndGetStruct(result.getProgFile(), protocolPackageMime, entityStruct);
        BStruct mediaTypeForBodyPart = BCompileUtil.createAndGetStruct(result.getProgFile(), protocolPackageMime,
                mediaTypeStruct);
        mediaTypeForBodyPart.setStringField(PRIMARY_TYPE_INDEX, "application");
        mediaTypeForBodyPart.setStringField(SUBTYPE_INDEX, "json");
        String key = "lang";
        String value = "ballerina";
        String jsonPart = "{\"" + key + "\":\"" + value + "\"}";
        bodyPart.setRefField(JSON_DATA_INDEX, new BJSON(jsonPart));
        bodyPart.setStringField(ENTITY_NAME_INDEX, "First Part");
        bodyPart.setRefField(MEDIA_TYPE_INDEX, mediaTypeForBodyPart);
        bodyPart.setBooleanField(IS_IN_MEMORY_INDEX, 1);

        ArrayList<BStruct> bodyParts = new ArrayList<>();
        bodyParts.add(bodyPart);
        BStructType typeOfBodyPart = bodyParts.get(0).getType();
        BStruct[] result = bodyParts.toArray(new BStruct[bodyParts.size()]);
        BRefValueArray partsArray = new BRefValueArray(result, typeOfBodyPart);
        entity.setRefField(MULTIPART_DATA_INDEX, partsArray);
        entity.setBooleanField(IS_IN_MEMORY_INDEX, 1);
        request.addNativeData(MESSAGE_ENTITY, entity);

        HttpUtil.prepareRequestWithMultiparts(cMsg, request);
        try {
            HttpPostRequestEncoder nettyEncoder = (HttpPostRequestEncoder) request.getNativeData(MULTIPART_ENCODER);
            HttpUtil.addMultipartsToCarbonMessage(cMsg, nettyEncoder);
        } catch (Exception e) {
            LOG.error("Error occured while adding multiparts to carbon message in testServiceGetMutliparts",
                    e.getMessage());
        }
        HTTPCarbonMessage response = Services.invokeNew(serviceResult, cMsg);
        Assert.assertNotNull(response, "Response message not found");
        Assert.assertEquals(new BJSON(getReturnValue(response)).value().get("lang").asText(), value);
    }

    /**
     * Get the response value from input stream.
     *
     * @param response carbon response
     * @return return value from  input stream as a string
     */
    private String getReturnValue(HTTPCarbonMessage response) {
        Reader reader;
        final int bufferSize = 1024;
        final char[] buffer = new char[bufferSize];
        final StringBuilder out = new StringBuilder();
        try {
            reader = new InputStreamReader(new HttpMessageDataStreamer(response).getInputStream(), UTF_8);
            while (true) {
                int size = reader.read(buffer, 0, buffer.length);
                if (size < 0) {
                    break;
                }
                out.append(buffer, 0, size);
            }
        } catch (IOException e) {
            LOG.error("Error occured while reading the response value in getReturnValue", e.getMessage());
        }
        return out.toString();
    }

}
