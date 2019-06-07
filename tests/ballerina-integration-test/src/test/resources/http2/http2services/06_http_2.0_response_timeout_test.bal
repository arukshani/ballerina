import ballerina/http;
import ballerina/io;
import ballerina/log;

listener http:Listener ep1 = new(9100, config = { httpVersion: "2.0" });
listener http:Listener ep2 = new(9101, config = { httpVersion: "2.0" });

http:Client priorOn = new("http://localhost:9101", config = { httpVersion: "2.0", http2Settings: {
                http2PriorKnowledge: true }, poolConfig: {} });

http:Client priorOff = new("http://localhost:9101", config = { httpVersion: "2.0", http2Settings: {
                http2PriorKnowledge: false }, poolConfig: {} });

@http:ServiceConfig {
    basePath: "/timeout"
}
service responseTimeout on ep1 {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/primaryResponse"
    }
    resource function testTimeout(http:Caller caller, http:Request req) {

        http:HttpFuture priorOnFuture = new;
        http:HttpFuture priorOffFuture = new;
        http:Request serviceReq = new;

        var priorOnResult = priorOn->submit("GET", "/h2/noResponse", serviceReq);
        var priorOffResult = priorOff->submit("GET", "/h2/noResponse", serviceReq);

        if (priorOnResult is http:HttpFuture) {
            priorOnFuture = priorOnResult;
        } else {
            log:printError("Error occurred while submitting a request with prior knowledge on",
            err = priorOnResult);
            return;
        }

        if (priorOffResult is http:HttpFuture) {
            priorOffFuture = priorOffResult;
        } else {
            log:printError("Error occurred while submitting a request with prior knowledge off",
            err = priorOffResult);
            return;
        }

        var priorOnResponse = priorOn->getResponse(priorOnFuture);
        var priorOffResponse = priorOff->getResponse(priorOffFuture);
        string response = handleResponse(priorOnResponse, "priorOn") + " -- " + handleResponse(priorOffResponse, "priorOff");
        checkpanic caller->respond(untaint response);

    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/pushResponse"
    }
    resource function testPushTimeout(http:Caller caller, http:Request req) {

        http:HttpFuture priorOnFuture = new;
        http:HttpFuture priorOffFuture = new;
        http:Request serviceReq = new;

        var priorOnResult = priorOn->submit("GET", "/h2/noPushResponse", serviceReq);
        var priorOffResult = priorOff->submit("GET", "/h2/noPushResponse", serviceReq);

        if (priorOnResult is http:HttpFuture) {
            priorOnFuture = priorOnResult;
        } else {
            log:printError("Error occurred while submitting a request with prior knowledge on", err = priorOnResult);
            return;
        }

        if (priorOffResult is http:HttpFuture) {
            priorOffFuture = priorOffResult;
        } else {
            log:printError("Error occurred while submitting a request with prior knowledge off", err = priorOffResult);
            return;
        }

        //string response = handlePushResponse(priorOn, priorOnFuture , "priorOn") + " -- " +
        //                                        handlePushResponse(priorOff, priorOffFuture , "priorOff");

        string response = handlePushResponse(priorOn, priorOnFuture , "priorOn");
        checkpanic caller->respond(untaint response);
    }
}

@http:ServiceConfig {
    basePath: "/h2"
}
service backend on ep2 {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/noResponse"
    }
    resource function noResponse(http:Caller caller, http:Request req) {
        //This resource does not return anything
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/noPushResponse"
    }
    resource function noPushResponse(http:Caller caller, http:Request req) {
        //This resource does not return the push response, only a promise

        http:PushPromise promise1 = new(path = "/resource1", method = "GET");
        var promiseResponse1 = caller->promise(promise1);
        if (promiseResponse1 is error) {
            log:printError("Error occurred while sending the promise1", err = promiseResponse1);
        }

        var response = caller->respond({ "response": { "name": "primary response" } });
        if (response is error) {
            log:printError("Error occurred while sending the primary response", err = response);
        }
    }
}

function handleResponse(http:Response|error result, string clientType) returns string {
    string response = "";
    if (result is http:Response) {
       response = clientType + ": " + "Response received";
    } else {
       response = clientType + ": " + <string>result.detail().message;
    }
    return response;
}

function handlePushResponse(http:Client h2Client, http:HttpFuture httpFuture, string clientType) returns string {

    string returnValue = clientType;
    http:PushPromise?[] promises = [];
    int promiseCount = 0;
    boolean hasPromise = h2Client->hasPromise(httpFuture);

    while (hasPromise) {
        http:PushPromise pushPromise = new;
        var nextPromiseResult = h2Client->getNextPromise(httpFuture);

        if (nextPromiseResult is http:PushPromise) {
            pushPromise = nextPromiseResult;
        } else {
            log:printError("Error occurred while fetching a push promise", err = nextPromiseResult);
            return returnValue;
        }
        returnValue += " -- " + "Received a promise for: " + pushPromise.path;
        promises[promiseCount] = pushPromise;
        promiseCount = promiseCount + 1;
        hasPromise = h2Client->hasPromise(httpFuture);
    }

    http:Response response = new;
    var result = h2Client->getResponse(httpFuture);
    if (result is http:Response) {
        response = result;
    } else {
        log:printError("Error occurred while fetching response", err = result);
        return returnValue;
    }
    var responsePayload = response.getJsonPayload();
    if (responsePayload is json) {
        returnValue += " -- " + responsePayload.toString();
    } else {
        log:printError("Expected response payload not received", err = responsePayload);
    }

    foreach var p in promises {
        http:PushPromise promise = <http:PushPromise> p;
        http:Response promisedResponse = new;

        var promisedResponseResult = h2Client->getPromisedResponse(promise);
        if (promisedResponseResult is http:Response) {
            promisedResponse = promisedResponseResult;
        } else {
            returnValue +=  " -- " + <string>promisedResponseResult.detail().message;
            return returnValue;
        }

        var promisedPayload = promisedResponse.getJsonPayload();
        if (promisedPayload is json) {
            log:printInfo("Promised response : " + promisedPayload.toString());
            returnValue +=  " -- " + promisedPayload.toString();
        } else {
            returnValue +=  " -- " + <string>promisedPayload.detail().message;
        }
    }
    return returnValue;
}

//priorOn: Idle timeout triggered before initiating inbound response -- priorOff: Idle timeout triggered before initiating inbound response