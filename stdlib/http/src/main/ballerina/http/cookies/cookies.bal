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

import ballerina/io;
import ballerina/log;
import ballerina/time;

# Represent server cookies that will be send from the server to the user agent.
#
# + name - Cookie name
# + value - Cookie value
# + path - URI path for which the cookie is valid
# + domain - Hosts to which the cookie will be sent
# + maxAge - Maximum lifetime of the cookie, represented as the number of seconds until the cookie expires. This has
#            precedence over date
# + expiry - Maximum lifetime of the cookie, represented as the date and time at which the cookie expires
# + secure - Client should include the cookie in an HTTP request only if the request is transmitted over a secure
#            channel
# + httpOnly - Omit the cookie when providing access to cookies via non - HTTP APIs
public type ServerCookie object {

    new(name, value) {}

    public string name;
    public string value;
    public string path;
    public string domain;
    public int maxAge = -1;
    public time:Time? expiry;
    public boolean secure;
    public boolean httpOnly;

    public function toString() returns string;
};

public function parseServerCookie(string header) returns ServerCookie?|error {
    ServerCookie? serverCookie;
    string[] bites = header.split("[;,]"); //Match semicolon or comma
    int i = 0;
    foreach bite in bites {
        string[] crumbs = bites[i].split("="); //split limit should be 2 but we dont have a function for that
        int lengthOfCrumbs = lengthof crumbs;
        if (lengthOfCrumbs > 2) {
            error parserError = {message: "Invalid cookie string detected"};
            return parserError;
        }
        //If there are more than 0 crumbs we know for sure that a name part is there in cookie name, value pair or
        //attribute value pair
        string name = lengthof crumbs > 0 ? crumbs[0].trim() : "";
        //If there are more than 1 crumbs we know for sure that a value part is there in cookie name, value pair or
        //attribute value pair
        string value = lengthof crumbs > 1 ? crumbs[1].trim() : "";

        //Remove quotes
        if (value.hasPrefix("\"") && value.hasSuffix("\"") && value.length() > 1) {
            value = value.substring(1, value.length() - 1);
        }

        match serverCookie {
            ServerCookie cookie => {
                if (PATH.equalsIgnoreCase(name)) {
                    serverCookie.path = value;
                } else if (DOMAIN.equalsIgnoreCase(name)) {
                    serverCookie.domain = value;
                } else if (MAX_AGE_FOR_COOKIE.equalsIgnoreCase(name)) {
                    serverCookie.maxAge = <int>value but { error => -1 };
                } else if (SECURE.equalsIgnoreCase(name)) {
                    serverCookie.secure = true;
                }else if (HTTPONLY.equalsIgnoreCase(name)) {
                    serverCookie.httpOnly = true;
                } else if (EXPIRES_FOR_COOKIE.equalsIgnoreCase(name)) {
                    i += 1;
                    cookie.expiry = time:parse(value + ", " + bites[i], time:TIME_FORMAT_RFC_1123);
                }
            }
            () => { serverCookie = new ServerCookie(name, value); }
        }
        i += 1;
    }
    return serverCookie;
}

# Represent client cookies that will be send from the client to server.
type ClientCookie object {
    @readonly string name;
    @readonly string value;
    @readonly string path;
    @readonly string domain;
    //There are few private properties that needs to be maintained for implementation. To be added later.
    //public function parseCookie(String header) returns ClientCookie[];
    //public function toString(ClientCookie[] cookie) returns String;
};

function ServerCookie::toString() returns string {
    string cookieString;
    //cookie name value pair
    cookieString = appendNameValuePair(cookieString, self.name, self.value);

    if (self.maxAge > 0) {
        cookieString = appendNameValuePair(cookieString, MAX_AGE_FOR_COOKIE, self.maxAge);
    }

    if (self.path != "") {
        cookieString = appendNameValuePair(cookieString, PATH, self.path);
    }

    if (self.domain != "") {
        cookieString = appendNameValuePair(cookieString, DOMAIN, self.domain);
    }

    if (self.secure) {
        cookieString = appendSingleValue(cookieString, SECURE);
    }

    if (self.httpOnly) {
        cookieString = appendSingleValue(cookieString, HTTPONLY);
    }

    match expiry {
        time:Time
    }

    return cookieString;
}

function appendNameValuePair(string cookieString, string name, string|int value) returns string {
    string returnValue = cookieString;
    returnValue += name;
    returnValue += EQUALS;
    match value {
        string stringVal => returnValue += stringVal;
        int intVal => returnValue += intVal;
    }
    returnValue += SEMICOLON;
    returnValue += SPACE;
    return returnValue;
}

function appendSingleValue(string cookieString, string name) returns string {
    string returnValue = cookieString;
    returnValue += name;
    returnValue += SEMICOLON;
    returnValue += SPACE;
    return returnValue;
}

@final string EQUALS = "=";
@final string SEMICOLON = ";";
@final string SPACE = " ";
@final string MAX_AGE_FOR_COOKIE = "Max-Age";
@final string EXPIRES_FOR_COOKIE = "Expires";
@final string PATH = "Path";
@final string DOMAIN = "Domain";
@final string SECURE = "Secure";
@final string HTTPONLY = "HTTPOnly";

@final string SET_COOKIE_HEADER = "Set-Cookie";
