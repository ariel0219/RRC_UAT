global class CIIS_GeoCounty_WebService_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
         // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"True":"True"}');
        res.setStatusCode(200);
        return res;
    }
}