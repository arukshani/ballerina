import ballerina/http;
import ballerina/io;
import ballerina/file;
import ballerina/mime;

endpoint http:Client clientEP {
    url:"http://localhost:9090/test"
};

endpoint http:Listener testEP {
    port:9090
};

@http:ServiceConfig {basePath:"/reuseObj"}
service<http:Service> testService_1 bind testEP {

    @http:ResourceConfig {
        methods:["GET"],
        path:"/request_with_entity"
    }
    getWithEntity(endpoint outboundEP, http:Request clientRequest) {
        http:Request clientReq = new;
        clientReq.setHeader("test1", "value1");
        http:Request newRequest = new;
        mime:Entity entity = check clientReq.getEntity();
        newRequest.setEntity(entity);
        http:Response firstResponse = check clientEP -> get("", request = clientReq);
        newRequest.setHeader("test2", "value2");
        http:Response secondResponse = check clientEP -> get("", request = newRequest);
        http:Response testResponse = new;
        string firstVal = check firstResponse.getStringPayload();
        string secondVal = check secondResponse.getStringPayload();
        testResponse.setStringPayload(firstVal + secondVal);
        _ = outboundEP -> respond(testResponse);
    }

    @http:ResourceConfig {
        methods:["GET"],
        path:"/request_without_entity"
    }
    getWithoutEntity(endpoint outboundEP, http:Request clientRequest) {
        http:Request clientReq = new;
        http:Response firstResponse = check clientEP -> get("", request = clientReq);
        http:Response secondResponse = check clientEP -> get("", request = clientReq);
        http:Response testResponse = new;
        string firstVal = check firstResponse.getStringPayload();
        string secondVal = check secondResponse.getStringPayload();
        testResponse.setStringPayload(firstVal + secondVal);
        _ = outboundEP -> respond(testResponse);
    }

    @http:ResourceConfig {
        methods:["GET"],
        path:"/request_with_datasource"
    }
    postWithEntity(endpoint outboundEP, http:Request clientRequest) {
        http:Request clientReq = new;
        clientReq.setStringPayload("String datasource");
        http:Response firstResponse = check clientEP -> post("", request = clientReq);
        http:Response secondResponse = check clientEP -> post("", request = clientReq);
        http:Response testResponse = new;
        string firstVal = check firstResponse.getStringPayload();
        string secondVal = check secondResponse.getStringPayload();
        testResponse.setStringPayload(firstVal + secondVal);
        _ = outboundEP -> respond(testResponse);
    }

    @http:ResourceConfig {
        methods:["GET"],
        path:"/request_with_bytechannel"
    }
    postWithByteChannel(endpoint outboundEP, http:Request clientRequest) {
        http:Request clientReq = new;
        clientReq.setFileAsPayload("datafiles/file.xml", contentType = mime:TEXT_XML);
        http:Response firstResponse = check clientEP -> post("", request = clientReq);
        http:Response secondResponse = check clientEP -> post("", request = clientReq);
        http:Response testResponse = new;
        xml firstVal = check firstResponse.getXmlPayload();
        xml secondVal = check secondResponse.getXmlPayload();
        testResponse.setStringPayload(firstVal.getTextValue() + secondVal.getTextValue());
        _ = outboundEP -> respond(testResponse);
    }
}

@http:ServiceConfig {basePath:"/test"}
service<http:Service> testService_2 bind testEP {

    @http:ResourceConfig {
        methods:["GET"],
        path:"/"
    }
    testForGet(endpoint outboundEP, http:Request clientRequest) {
        http:Response response = new;
        response.setStringPayload("Hello from GET!");
        _ = outboundEP -> respond(response);
    }

    @http:ResourceConfig {
        methods:["POST"],
        path:"/"
    }
    testForPost(endpoint outboundEP, http:Request clientRequest) {
        http:Response response = new;
        response.setStringPayload("Hello from POST!");
        _ = outboundEP -> respond(response);
    }

    @http:ResourceConfig {
        methods:["POST"],
        path:"/consumeChannel"
    }
    testRequestBody(endpoint outboundEP, http:Request clientRequest) {
        http:Response response = new;
        xml xmlPayload = check clientRequest.getXmlPayload();
        response.setXmlPayload(xmlPayload);
        _ = outboundEP -> respond(response);
    }
}