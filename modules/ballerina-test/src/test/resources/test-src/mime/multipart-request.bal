import ballerina.net.http;

import ballerina.mime;


@http:configuration{basePath:"/test"}
service<http> helloServer {

    @http:resourceConfig {
        methods:["POST"],
        path:"/jsonbodypart"
    }
    resource multipart1 (http:Connection conn, http:Request request) {
        mime:Entity[] bodyParts = request.getMultiparts();
        json jsonContent = mime:getJson(bodyParts[0]);
        http:Response res = {};
        res.setJsonPayload(jsonContent);
        _ = conn.respond(res);
    }

    @http:resourceConfig {
        path:"/multiparts"
    }
    resource multipart2 (http:Connection conn, http:Request req) {
        http:Response res = {};

        _ = conn.respond(res);
    }

    @http:resourceConfig {
        path:"/bodyparts3"
    }
    resource multipart3 (http:Connection conn, http:Request req) {
        http:Response res = {};

        _ = conn.respond(res);
    }
}