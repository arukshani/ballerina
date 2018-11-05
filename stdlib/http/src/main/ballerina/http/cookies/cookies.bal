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

# Represents a cookie that is sent from the server to the client.
#
# + name - Specifies the name of the cookie
# + value - Specifies the value of the cookie
# + path - Indicates the URI path to which the cookie is valid
# + domain - Indicates the hosts to which the cookie is sent
# + maxAge - Maximum lifetime of the cookie, represented as the number of seconds until the cookie expires. This has
#            precedence over date.
# + expiry - Maximum lifetime of the cookie, represented as the date and time at which the cookie expires
# + secure - Indicates that the client should include the cookie in an HTTP request only if the request is transmitted
#            over a secure channel
# + httpOnly - Omits the cookie when providing access to cookies via non - HTTP APIs
public type ServerCookie object {

    public new(name, value) {}

    public string name;
    public string value;
    public string path;
    public string domain;
    public int maxAge = -1;
    public time:Time? expiry;
    public boolean secure;
    public boolean httpOnly;

    # String representation of the server cookie which can be used as a header value for `set-cookie` header.
    #
    # + return - `ServerCookie` in `string` format
    public function toString() returns string;
};

# Represents a cookie that is sent from the client to the server.
#
# + name - Specifies the name of the cookie
# + value - Specifies the value of the cookie
# + path - Indicates the URI path to which the cookie is sent
# + domain - Indicates the hosts to which the cookie is sent
public type ClientCookie object {

    public new(name, value) {}

    @readonly public string name;
    @readonly public string value;
    @readonly public string path;
    @readonly public string domain;

};

# `CookieJar` contains a collection of HTTP cookies in `ServerCookie` format.
public type CookieJar object {

    # Gets all the cookies stored in the cookie jar.
    #
    # + return - An array of `ServerCookies` or an `error` if the cookie jar is empty
    public extern function getCookies() returns ServerCookie[]|error;

    # Deletes a given `ServerCookie` from the cookie jar.
    public extern function deleteCookie(ServerCookie serverCookie);

    # Deletes all `ServerCookies` stored in the cookie jar.
    public extern function clear();

    # Adds a given `ServerCookie` to the cookie jar. Cookies can be added to the cookie jar only by the HTTP client,
    # hence this function has not been exposed to the public.
    extern function addCookie(ServerCookie serverCookie);
};

# Given a value of the `set-cookie` header, construct a `ServerCookie`.
#
# + headerValue - Represents a valid `set-cookie` header value
# + return - A `ServerCookie` or an `error`
public function parseServerCookie(string headerValue) returns ServerCookie?|error {

    ServerCookie? serverCookie;
    string[] bites = headerValue.split(SEMICOLON);
    foreach bite in bites {
        string name;
        string value;

        match getCookieNameValuePair(bite) {
            (string, string) nameValuePair => {
                var (cookieName,cookieValue) = nameValuePair;
                name = cookieName;
                value = cookieValue;
            }
            error err => return err;
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
                    try {
                        cookie.expiry = time:parse(value, time:TIME_FORMAT_RFC_1123);
                    } catch (error err) {
                        string errMsg = "Error occurred while parsing expiry date in set-cookie: " + err.message;
                        error parserError = {message: errMsg};
                        return parserError;
                    }
                }
            }
            () => { serverCookie = new ServerCookie(name, value); }
        }
    }
    return serverCookie;
}

# Given a value of the `cookie` header, construct an array of `ClientCookies`. Parsing adheres to the RFC6265. This is
# balantly different from how the RFC2965 parses the cookie header. All the attributes that start with `$` mark are ignored.
#
# + headerValue - Valid `set-cookie` header value
# + return - An array of `ClientCookies` or an `error`
public function parseClientCookie(string headerValue) returns ClientCookie[]|error {
    ClientCookie[] clientCookies;
    string[] bites = headerValue.split(SEMICOLON);
    int i = 0;
    foreach bite in bites {
        string name;
        string value;

        match getCookieNameValuePair(bite) {
            (string, string) nameValuePair => {
                var (cookieName,cookieValue) = nameValuePair;
                name = cookieName;
                value = cookieValue;
            }
            error err => return err;
        }

        if (!name.hasSuffix(DOLLAR)) {
            ClientCookie clientCookie = new ClientCookie(name, value);
            clientCookies[i] = clientCookie;
        }
        i = i + 1;
    }
    return clientCookies;
}

function getCookieNameValuePair(string bite) returns (string,string)|error {
    string[] crumbs = bite.split(EQUALS); //split limit should be 2 but we dont have a function for that
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
    if (value.hasPrefix(QUOTE) && value.hasSuffix(QUOTE) && value.length() > 1) {
        value = value.substring(1, value.length() - 1);
    }
    return (name,value);
}

function ServerCookie::toString() returns string {
    string cookieString;
    //cookie name value pair
    cookieString = appendNameValuePair(cookieString, self.name, self.value);

    if (self.maxAge > 0) {
        cookieString = appendAttribute(cookieString, MAX_AGE_FOR_COOKIE, self.maxAge);
    }

    match self.expiry {
        time:Time expires => {
            cookieString = appendAttribute(cookieString, EXPIRES_FOR_COOKIE,
                                expires.format(time:TIME_FORMAT_RFC_1123));
        }
        () => {}
    }

    if (self.path != "") {
        cookieString = appendAttribute(cookieString, PATH, self.path);
    }

    if (self.domain != "") {
        cookieString = appendAttribute(cookieString, DOMAIN, self.domain);
    }

    if (self.secure) {
        cookieString = appendSingleValue(cookieString, SECURE);
    }

    if (self.httpOnly) {
        cookieString = appendSingleValue(cookieString, HTTPONLY);
    }

    return cookieString;
}

# String representation of an array of client cookies which can be used as a header value for the `cookie` header.
#
# + cookies - Represents an array of `ClientCookies`
# + return - An array of client cookies in string format
public function convertClientCookiestoString(ClientCookie[] cookies) returns string {
    string cookieString;
    int i = 0;
    foreach cookie in cookies {
        //cookie name value pair
        cookieString = appendNameValuePair(cookieString, cookie.name, cookie.value);
        i = i + 1;
        if (lengthof cookies != i) {
            cookieString = appendSemiColon(cookieString);
        }
    }
    return cookieString;
}

function appendNameValuePair(string cookieString, string name, string value) returns string {
    string returnValue = cookieString;
    returnValue += name;
    returnValue += EQUALS;
    returnValue += value;
    return returnValue;
}

function appendAttribute(string cookieString, string name, string|int value) returns string {
    string returnValue = appendSemiColon(cookieString);
    returnValue += name;
    returnValue += EQUALS;
    match value {
        string stringVal => returnValue += stringVal;
        int intVal => returnValue += intVal;
    }
    return returnValue;
}

function appendSingleValue(string cookieString, string name) returns string {
    string returnValue = appendSemiColon(cookieString);
    returnValue += name;
    return returnValue;
}

function appendSemiColon(string cookieString) returns string {
    string returnValue = cookieString;
    returnValue += SEMICOLON;
    returnValue += SPACE;
    return returnValue;
}

@final string EQUALS = "=";
@final string SEMICOLON = ";";
@final string SPACE = " ";
@final string DOLLAR = "$";
@final string QUOTE = "\"";
@final string MAX_AGE_FOR_COOKIE = "Max-Age";
@final string EXPIRES_FOR_COOKIE = "Expires";
@final string PATH = "Path";
@final string DOMAIN = "Domain";
@final string SECURE = "Secure";
@final string HTTPONLY = "HttpOnly";
