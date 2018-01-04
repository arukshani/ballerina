import ballerina.net.http;

@http:configuration {basePath:"/cbr"}
service<http> contentBasedRouting {
    @Description {value:"http:POST{} annotation declares the HTTP method."}
    @http:resourceConfig {
        methods:["POST"],
        path:"/route"
    }
    resource cbrResource (http:Connection conn, http:Request req) {
        endpoint<http:HttpClient> locationEP {
            create http:HttpClient("http://www.mocky.io", {});
        }
        //Get JSON payload from the request message.
        json jsonMsg = req.getJsonPayload();
        //Get the string value relevant to the key "name".
        string nameString;
        nameString, _ = (string)jsonMsg["name"];
        http:Response clientResponse;
        http:HttpConnectorError err;
        if (nameString == "sanFrancisco") {
            //"post" represent the POST action of HTTP connector. Route payload to relevant service as the server accept the entity enclosed.
            clientResponse, err = locationEP.post("/v2/594e018c1100002811d6d39a", {});
        } else {
            clientResponse, err = locationEP.post("/v2/594e026c1100004011d6d39c", {});
        }
        //Native function "respond" sends back the clientResponse to the caller.
        http:Response res = {};
        if (err != null) {
            res.setStatusCode(500);
            res.setStringPayload(err.msg);
            _ = conn.respond(res);
        } else {
            _ = conn.respond(clientResponse);
        }
    }
}
