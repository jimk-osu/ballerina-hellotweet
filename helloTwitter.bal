import ballerina/http;
import ballerina/config;
import wso2/twitter;
import ballerinax/kubernetes;

endpoint twitter:Client twitterClient {
   clientId: config:getAsString("consumerKey"),
   clientSecret: config:getAsString("consumerSecret"),
   accessToken: config:getAsString("accessToken"),
   accessTokenSecret: config:getAsString("accessTokenSecret")
};

@kubernetes:Service {
    name:"bal-hello-svc",
    serviceType: "NodePort"
}

@kubernetes:Deployment {
    image: "localhost:5000/helloballerina:v1",
    name:"bal-hello-svc",
    replicas: 2,
    namespace: "ballerina"
}

endpoint http:Listener localListener {
    port: 9090
};

@kubernetes:ConfigMap {
    ballerinaConf:"./conf/twitter.toml"
}
@http:ServiceConfig {
    basePath: "/"
}
service<http:Service> olf bind { port: 9090 } {
    @http:ResourceConfig {
        path: "/",
        methods: ["GET"]
    }
    hi (endpoint caller, http:Request request) {
        http:Response response = new;

        response.setTextPayload("Hi Ohio Linux Fest!", contentType = "text/plain");

        _ = caller -> respond(response);
    }
    @http:ResourceConfig {
        path: "/tweet",
        methods: ["POST"]
    }
    tweet (endpoint caller, http:Request request){
        string status = check request.getTextPayload();
        twitter:Status st = check twitterClient -> tweet(status);

        http:Response response = new;
        response.setTextPayload("ID:" + <string>st.id + "\n");

        _ = caller -> respond(response);
    }
}