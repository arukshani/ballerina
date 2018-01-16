/*
 * Copyright (c) 2018, WSO2 Inc. (http://wso2.com) All Rights Reserved.
 * <p>
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.ballerinalang.runtime.message;

import io.netty.buffer.ByteBufAllocator;
import io.netty.handler.codec.http.HttpContent;
import io.netty.handler.codec.http.multipart.HttpPostRequestEncoder;
import org.ballerinalang.util.exceptions.BallerinaException;

import java.io.IOException;

/**
 * This class holds data related to multiparts in a request message.
 */
public class MultipartDataSource extends BallerinaMessageDataSource {

    private HttpPostRequestEncoder nettyEncoder;

    public MultipartDataSource(HttpPostRequestEncoder nettyEncoder) {
        this.nettyEncoder = nettyEncoder;
    }

    @Override
    public void serializeData() {

            HttpContent content;
            while (!nettyEncoder.isEndOfInput()) {
                content = nettyEncoder.readChunk(ByteBufAllocator.DEFAULT);

            }
            nettyEncoder.cleanFiles();
            //outputStream.write(value);
        }
}

