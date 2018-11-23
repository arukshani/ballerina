import ballerina/http;

//endpoint http:NonListener mockEP {
//    port:9090
//};

//listener http:MockServer mockEP = new(9090);

service hello on new http:MockServer(9090) {

    //@http:ResourceConfig {
    //    path:"/protocol",
    //    methods:["GET"]
    //}
    resource function protocol (http:Caller caller, http:Request req) {
        http:Response res = new;
        json connectionJson = {protocol:caller.protocol};
        res.statusCode = 200;
        res.setJsonPayload(untaint connectionJson);
        _ = caller -> respond(res);
    }

    //@http:ResourceConfig {
    //    path:"/local",
    //    methods:["GET"]
    //}
    resource function local (http:Caller caller, http:Request req) {
        http:Response res = new;
        json connectionJson = {local:{host:caller.local.host, port:caller.local.port}};
        res.statusCode = 200;
        res.setJsonPayload(untaint connectionJson);
        _ = caller -> respond(res);
    }
}
