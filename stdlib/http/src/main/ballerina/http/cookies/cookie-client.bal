// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/config;
import ballerina/io;
import ballerina/log;
import ballerina/mime;
import ballerina/time;

# Provides cookie functionality across HTTP client actions.
#
# + serviceUri - Target service url
# + config - HTTP ClientEndpointConfig to be used for HTTP client invocation
# + cookieConfig - Configurations associated with cookies
# + httpClient - HTTP client for outbound HTTP requests
public type CookieClient object {

    public string serviceUri;
    public ClientEndpointConfig config;
    public CookieConfig cookieConfig;
    public CallerActions httpClient;
    public CookieJar clientCookieJar;

    # Create a redirect client with the given configurations.
    #
    # + serviceUri - Target service url
    # + config - HTTP ClientEndpointConfig to be used for HTTP client invocation
    # + redirectConfig - Configurations associated with redirect
    # + httpClient - HTTP client for outbound HTTP requests
    public new(serviceUri, config, cookieConfig, clientCookieJar, httpClient) {
        self.serviceUri = serviceUri;
        self.config = config;
        self.cookieConfig = cookieConfig;
        self.httpClient = httpClient;
        self.clientCookieJar = clientCookieJar;
    }

    # If the received response for the `get()` action is redirect eligible, redirect will be performed automatically
    # by this `get()` function.
    #
    # + path - Resource path
    # + message - An optional HTTP outbound request message or any payload of type `string`, `xml`, `json`,
    #             `byte[]`, `io:ReadableByteChannel` or `mime:Entity[]`
    # + return - The HTTP `Response` message, or an error if the invocation fails
    public function get(string path, Request|string|xml|json|byte[]|io:ReadableByteChannel|mime:Entity[]|() message = ())
                                                                                            returns Response|error {
        log:printInfo("Cookie client");
        Request request = buildRequest(message);

        ClientCookie[] matchedCookies = [];
        //Pick releavant cookies from cookie jar
        ServerCookie[] cookies = self.clientCookieJar.getCookies();
        int i = 0;
        foreach cookie in cookies {
            //Is expired
            match cookie.expiry {
                time:Time expiryDate => {
                    int currentTime = time:currentTime().time;
                    if (expiryDate > currentTime) {
                        if(cookieEligible(cookie, self)) {
                            ClientCookie matchedCookie = new (cookie.name, cookie.value);
                            matchedCookies[i] = matchedCookie;
                            i = i+1;
                        }
                    } else {
                        //TODO: Remove from cookie jar

                    }
                }
                () => {
                    if(cookieEligible(cookie, self)) {
                        ClientCookie matchedCookie = new (cookie.name, cookie.value);
                        matchedCookies[i] = matchedCookie;
                        i = i +1;
                    }
                }
            }
        }

        if (lengthof matchedCookies > 0) {
             request.addCookies(matchedCookies);
        }

        match self.httpClient.get(path, message = request) {
            Response response => {
                match response.getCookies() {
                    ServerCookie[] serverCookies => {
                        foreach(cookie in serverCookies) {
                            self.clientCookieJar.addCookie(cookie);
                        }
                    }
                    error parseErr => {
                        log:printWarn(parseErr.message);
                    }
                }
                return response;
            }
            error err => { return err; }
        }
    }

    # If the received response for the `post()` action is redirect eligible, redirect will be performed automatically
    # by this `post()` function.
    #
    # + path - Resource path
    # + message - An HTTP outbound request message or any payload of type `string`, `xml`, `json`, `byte[]`,
    #             `io:ReadableByteChannel` or `mime:Entity[]`
    # + return - The HTTP `Response` message, or an error if the invocation fails
    public function post(string path, Request|string|xml|json|byte[]|io:ReadableByteChannel|mime:Entity[]|()
    message) returns Response|error {
        Request request = buildRequest(message);
        return self.httpClient.post(path, request);
    }

    # If the received response for the `head()` action is redirect eligible, redirect will be performed automatically
    # by this `head()` function.
    #
    # + path - Resource path
    # + message - An optional HTTP outbound request message or or any payload of type `string`, `xml`, `json`,
    #             `byte[]`, `io:ReadableByteChannel` or `mime:Entity[]`
    # + return - The HTTP `Response` message, or an error if the invocation fails
    public function head(string path, Request|string|xml|json|byte[]|io:ReadableByteChannel|mime:Entity[]|()
    message = ()) returns Response|error {
        Request request = buildRequest(message);
        return self.httpClient.head(path, message = request);
    }

    # If the received response for the `put()` action is redirect eligible, redirect will be performed automatically
    # by this `put()` function.
    #
    # + path - Resource path
    # + message - An HTTP outbound request message or any payload of type `string`, `xml`, `json`, `byte[]`,
    #             `io:ReadableByteChannel` or `mime:Entity[]`
    # + return - The HTTP `Response` message, or an error if the invocation fails
    public function put(string path, Request|string|xml|json|byte[]|io:ReadableByteChannel|mime:Entity[]|()
    message) returns Response|error {
        Request request = buildRequest(message);
        return self.httpClient.put(path, request);
    }

    # The `forward()` function is used to invoke an HTTP call with inbound request's HTTP verb.
    #
    # + path - Resource path
    # + request - An HTTP inbound request message
    # + return - The HTTP `Response` message, or an error if the invocation fails
    public function forward(string path, Request request) returns Response|error {
        return self.httpClient.forward(path, request);
    }

    # The `execute()` sends an HTTP request to a service with the specified HTTP verb. Redirect will be performed
    # only for HTTP methods.
    #
    # + path - Resource path
    # + message - An HTTP outbound request message or any payload of type `string`, `xml`, `json`, `byte[]`,
    #             `io:ReadableByteChannel` or `mime:Entity[]`
    # + return - The HTTP `Response` message, or an error if the invocation fails
    public function execute(string httpVerb, string path, Request|string|xml|json|byte[]|io:ReadableByteChannel|mime:Entity[]|()
    message) returns Response|error {
        Request request = buildRequest(message);
        return self.httpClient.execute(httpVerb, path, request);
    }

    # If the received response for the `patch()` action is redirect eligible, redirect will be performed automatically
    # by this `patch()` function.
    #
    # + path - Resource path
    # + message - An HTTP outbound request message or any payload of type `string`, `xml`, `json`, `byte[]`,
    #             `io:ReadableByteChannel` or `mime:Entity[]`
    # + return - The HTTP `Response` message, or an error if the invocation fails
    public function patch(string path, Request|string|xml|json|byte[]|io:ReadableByteChannel|mime:Entity[]|()
    message) returns Response|error {
        Request request = buildRequest(message);
        return self.httpClient.patch(path, request);
    }

    # If the received response for the `delete()` action is redirect eligible, redirect will be performed automatically
    # by this `delete()` function.
    #
    # + path - Resource path
    # + message - An HTTP outbound request message or any payload of type `string`, `xml`, `json`, `byte[]`,
    #             `io:ReadableByteChannel` or `mime:Entity[]`
    # + return - The HTTP `Response` message, or an error if the invocation fails
    public function delete(string path, Request|string|xml|json|byte[]|io:ReadableByteChannel|mime:Entity[]|()
    message) returns Response|error {
        Request request = buildRequest(message);
        return self.httpClient.delete(path, request);
    }

    # If the received response for the `options()` action is redirect eligible, redirect will be performed automatically
    # by this `options()` function.
    #
    # + path - Resource path
    # + message - An optional HTTP outbound request message or any payload of type `string`, `xml`, `json`,
    #             `byte[]`, `io:ReadableByteChannel` or `mime:Entity[]`
    # + return - The HTTP `Response` message, or an error if the invocation fails
    public function options(string path, Request|string|xml|json|byte[]|io:ReadableByteChannel|mime:Entity[]|()
    message = ()) returns Response|error {
        Request request = buildRequest(message);
        return self.httpClient.options(path, message = request);
    }

    # Submits an HTTP request to a service with the specified HTTP verb.
    # The `submit()` function does not give out a `Response` as the result,
    # rather it returns an `HttpFuture` which can be used to do further interactions with the endpoint .
    #
    # + httpVerb - The HTTP verb value
    # + path - The resource path
    # + message - An HTTP outbound request message or any payload of type `string`, `xml`, `json`, `byte[]`,
    #             `io:ReadableByteChannel` or `mime:Entity[]`
    # + return - An `HttpFuture` that represents an asynchronous service invocation, or an error if the submission fails
    public function submit(string httpVerb, string path, Request|string|xml|json|byte[]|io:ReadableByteChannel|mime:Entity[]|()
    message) returns HttpFuture|error {
        Request request = buildRequest(message);
        return self.httpClient.submit(httpVerb, path, request);
    }

    # Retrieves the `Response` for a previously submitted request.
    #
    # + httpFuture - The `HttpFuture` relates to a previous asynchronous invocation
    # + return - An HTTP response message, or an error if the invocation fails
    public function getResponse(HttpFuture httpFuture) returns Response|error {
        return self.httpClient.getResponse(httpFuture);
    }

    # Checks whether a `PushPromise` exists for a previously submitted request.
    #
    # + httpFuture - The `HttpFuture` relates to a previous asynchronous invocation
    # + return - A `boolean` that represents whether a `PushPromise` exists
    public function hasPromise(HttpFuture httpFuture) returns (boolean) {
        return self.httpClient.hasPromise(httpFuture);
    }

    # Retrieves the next available `PushPromise` for a previously submitted request.
    #
    # + httpFuture - The `HttpFuture` relates to a previous asynchronous invocation
    # + return - An HTTP Push Promise message, or an error if the invocation fails
    public function getNextPromise(HttpFuture httpFuture) returns PushPromise|error {
        return self.httpClient.getNextPromise(httpFuture);
    }

    # Retrieves the promised server push `Response` message.
    #
    # + promise - The related `PushPromise`
    # + return - A promised HTTP `Response` message, or an error if the invocation fails
    public function getPromisedResponse(PushPromise promise) returns Response|error {
        return self.httpClient.getPromisedResponse(promise);
    }

    # Rejects a `PushPromise`.
    # When a `PushPromise` is rejected, there is no chance of fetching a promised response using the rejected promise.
    #
    # + promise - The Push Promise to be rejected
    public function rejectPromise(PushPromise promise) {
        self.httpClient.rejectPromise(promise);
    }
};

//Check whether the cookie is eligible to be sent with the request
function cookieEligible(ServerCookie cookie, CookieClient client) returns boolean {
    //Is secure
    boolean isSecureMatch = !cookie.secure || client.serviceUri.hasSuffix(HTTPS_SCHEME);
    if (isSecureMatch) {
        //TODO: Domain match
        //TODO: Path match
        return true;
    }
    return false;
}
