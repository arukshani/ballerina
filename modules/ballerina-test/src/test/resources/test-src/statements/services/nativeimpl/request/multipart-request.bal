import ballerina.net.http;

import ballerina.mime;


@http:configuration{basePath:"/test"}
service<http> helloServer {

    @http:resourceConfig {
        path:"/bodypart1"
    }
    resource multipart1 (http:Connection conn, http:Request req) {
        mime:Entity requestEntity = req.getEntity();
        mime:Entity[] bodyParts = requestEntity.multipartData;
        json jsonPart = mime:getJson(bodyParts[0]);
        http:Response res = {};
        res.setJsonPayload(jsonPart);
        _ = conn.respond(res);
    }

    @http:resourceConfig {
        path:"/bodypart2"
    }
    resource multipart2 (http:Connection conn, http:Request req) {
        http:Response res = {};

        _ = conn.respond(res);
    }

    @http:resourceConfig {
        path:"/bodypart3"
    }
    resource multipart3 (http:Connection conn, http:Request req) {
        http:Response res = {};

        _ = conn.respond(res);
    }
}