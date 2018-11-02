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

    public new(name, value) {}

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

# Represent client cookies that will be send from the client to server.
public type ClientCookie object {

    public new(name, value) {}

    @readonly public string name;
    @readonly public string value;
    @readonly public string path;
    @readonly public string domain;

    //public function toString(ClientCookie[] cookie) returns String;
};

public function parseServerCookie(string header) returns ServerCookie?|error {
    ServerCookie? serverCookie;
    string[] bites = header.split(";");
    foreach bite in bites {
        string[] crumbs = bite.split("="); //split limit should be 2 but we dont have a function for that
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
                    try {
                        cookie.expiry = time:parse(value, time:TIME_FORMAT_RFC_1123);
                    }catch (error err) {
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

//Adheres to RFC6265. This is balantly different from how RFC2965 parses the cookie header. All the attributes that
//starts with $ mark are ignored.
public function parseClientCookie(string header) returns ClientCookie[]|error {
    ClientCookie[] clientCookies;
    string[] bites = header.split(";");
    int i = 0;
    foreach bite in bites {
        string[] crumbs = bite.split("="); //split limit should be 2 but we dont have a function for that
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
        if (!name.hasSuffix("$")) {
            ClientCookie clientCookie = new ClientCookie(name, value);
            clientCookies[i] = clientCookie;
        }
        i = i + 1;
    }
    return clientCookies;
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

public type CookieJar object {

    //private ServerCookie[] serverCookies;
    //
    //public function getCookies() returns ServerCookie[] {
    //    return serverCookies;
    //}
    //
    //public function clear() {
    //    serverCookies = [];
    //}
    //
    //function addCookie(ServerCookie serverCookie) {
    //
    //    //TODO: Remove matching serverCookie from servercookie[]
    //    //TODO: If it is not expired add it. (!cookie.isExpired(new Date()))
    //
    //    int noOfCookies = lengthof serverCookies;
    //    if (noOfCookies != 0) {
    //        serverCookies[noOfCookies] = serverCookie;
    //    } else {
    //        serverCookies[0] = serverCookie;
    //    }
    //}

    public extern function getCookies() returns ServerCookie[];

    extern function clear();

    //Cookie will be added to cookie jar based on the rules defined in RFC6265
    extern function addCookie(ServerCookie serverCookie);

    //extern function selectEligibleCookies() returns ServerCookie[];
};

@final string EQUALS = "=";
@final string SEMICOLON = ";";
@final string SPACE = " ";
@final string MAX_AGE_FOR_COOKIE = "Max-Age";
@final string EXPIRES_FOR_COOKIE = "Expires";
@final string PATH = "Path";
@final string DOMAIN = "Domain";
@final string SECURE = "Secure";
@final string HTTPONLY = "HttpOnly";

@final string SET_COOKIE_HEADER = "set-cookie";
@final string COOKIE_HEADER = "cookie";
