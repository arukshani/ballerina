import ballerina/http;
import ballerina/io;

function testSetServerCookies(ServerCookie[] serverCookies) {
    http:Response response = new;
    response.setCookies(serverCookies);
    response.getCookies();
}
