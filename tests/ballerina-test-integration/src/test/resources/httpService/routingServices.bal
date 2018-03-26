import ballerina/net.http;
import ballerina/io;
import ballerina/mime;

endpoint http:ServiceEndpoint serviceEP {
    port:9090
};

endpoint http:ClientEndpoint nasdaqEP {
    targets: [{uri:"http://localhost:9090/nasdaqStocks"}]
};

endpoint http:ClientEndpoint nyseEP {
    targets: [{uri:"http://localhost:9090/nyseStocks"}]
};

@http:ServiceConfig {basePath:"/cbr"}
service<http:Service> contentBasedRouting bind serviceEP{

    @http:ResourceConfig {
        methods:["POST"],
        path:"/"
    }
    cbrResource (endpoint conn, http:Request req) {
        string nyseString = "nyse";
        var jsonMsg = req.getJsonPayload();
        string nameString;
        match jsonMsg {
            mime:EntityError payloadError => io:println("Error getting payload");
            json payload =>  {
                var result =? <string>payload.name;
                nameString = result;
            }
        }
        http:Request clientRequest = {};
        http:Response clientResponse = {};
        if (nameString == nyseString) {
            var result = nyseEP -> post("/stocks", clientRequest);
            match result {
                http:HttpConnectorError err => {
                    clientResponse.statusCode = 500;
                    clientResponse.setStringPayload("Error sending request");
                    _ = conn -> respond(clientResponse);
                }
                http:Response returnResponse => _ = conn -> forward(returnResponse);
            }
        } else {
            var result = nasdaqEP -> post("/stocks", clientRequest);
            match result {
                http:HttpConnectorError err => {
                    clientResponse.statusCode = 500;
                    clientResponse.setStringPayload("Error sending request");
                    _ = conn -> respond(clientResponse);
                }
                http:Response returnResponse => _ = conn -> forward(returnResponse);
            }
        }
    }
}

@http:ServiceConfig {basePath:"/hbr"}
service<http:Service> headerBasedRouting bind serviceEP{

    @http:ResourceConfig {
        methods:["GET"],
        path:"/"
    }
    hbrResource (endpoint conn, http:Request req) {
        string nyseString = "nyse";
        var nameString = req.getHeader("name");

        http:Request clientRequest = {};
        http:Response clientResponse = {};
        if (nameString == nyseString) {
            var result = nyseEP -> post("/stocks", clientRequest);
            match result {
                http:HttpConnectorError err => {
                    clientResponse.statusCode = 500;
                    clientResponse.setStringPayload("Error sending request");
                    _ = conn -> respond(clientResponse);
                }
                http:Response returnResponse => _ = conn -> forward(returnResponse);
            }
        } else {
            var result = nasdaqEP -> post("/stocks", clientRequest);
            match result {
                http:HttpConnectorError err => {
                    clientResponse.statusCode = 500;
                    clientResponse.setStringPayload("Error sending request");
                    _ = conn -> respond(clientResponse);
                }
                http:Response returnResponse => _ = conn -> forward(returnResponse);
            }
        }
    }
}

@http:ServiceConfig {basePath:"/nasdaqStocks"}
service<http:Service> nasdaqStocksQuote bind serviceEP {

    @http:ResourceConfig {
        methods:["POST"]
    }
    stocks (endpoint conn, http:Request req) {
        json payload = {"exchange":"nasdaq", "name":"IBM", "value":"127.50"};
        http:Response res = {};
        res.setJsonPayload(payload);
        _ = conn -> respond(res);
    }
}

@http:ServiceConfig {basePath:"/nyseStocks"}
service<http:Service> nyseStockQuote bind serviceEP {

    @http:ResourceConfig {
        methods:["POST"]
    }
    stocks (endpoint conn, http:Request req) {
        json payload = {"exchange":"nyse", "name":"IBM", "value":"127.50"};
        http:Response res = {};
        res.setJsonPayload(payload);
        _ = conn -> respond(res);
    }
}
