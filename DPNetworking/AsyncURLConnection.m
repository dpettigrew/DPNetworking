//
//  AsyncURLConnection.m
//
//  Copyright (c) David Pettigrew. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//      * Neither the name of the David Pettigrew nor the
//        names of its contributors may be used to endorse or promote products
//        derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL David Pettigrew BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "AsyncURLConnection.h"
#import "NSData+Base64.h" // From http://svn.cocoasourcecode.com/MGTwitterEngine-1.0.8/


@interface AsyncURLConnection () {
    NSUInteger _httpStatus;
}

@end

@implementation AsyncURLConnection

- (id)requestUrl:(NSString *)requestUrl httpMethod:(NSString *)httpMethod bodyText:(NSString *)bodyText httpHeaders:(NSDictionary *)httpHeaders completeBlock:(completeBlock_t)aCompleteBlock errorBlock:(errorBlock_t)anErrorBlock {
#ifdef HTTP_LOGGING
    NSLog(@"Sending HTTP %@ request - %@", httpMethod, requestUrl);
#endif
    return [self requestUrl:requestUrl httpMethod:httpMethod userName:nil userPassword:nil bodyText:bodyText httpHeaders:httpHeaders completeBlock:aCompleteBlock errorBlock:anErrorBlock];
}

- (id)requestUrl:(NSString *)requestUrl httpHeaders:(NSDictionary *)httpHeaders completeBlock:(completeBlock_t)aCompleteBlock errorBlock:(errorBlock_t)anErrorBlock {
#ifdef HTTP_LOGGING
    NSLog(@"Sending HTTP request - %@", requestUrl);
#endif
    return [self requestUrl:requestUrl userName:nil userPassword:nil httpHeaders:(NSDictionary *)httpHeaders completeBlock:aCompleteBlock errorBlock:anErrorBlock];
}

- (id)requestUrl:(NSString *)requestUrl userName:(NSString *)userName userPassword:(NSString *)userPassword httpHeaders:(NSDictionary *)httpHeaders completeBlock:(completeBlock_t)aCompleteBlock errorBlock:(errorBlock_t)anErrorBlock {
#ifdef HTTP_LOGGING
    NSLog(@"Sending HTTP request - %@", requestUrl);
#endif
    return [self initWithRequestUrl:requestUrl userName:userName userPassword:userPassword bodyText:nil httpHeaders:httpHeaders completeBlock:aCompleteBlock errorBlock:anErrorBlock];
}

- (id)requestUrl:(NSString *)requestUrl httpMethod:(NSString *)httpMethod userName:(NSString *)userName userPassword:(NSString *)userPassword bodyText:(NSString *)bodyText httpHeaders:(NSDictionary *)httpHeaders completeBlock:(completeBlock_t)aCompleteBlock errorBlock:(errorBlock_t)anErrorBlock {
#ifdef HTTP_LOGGING
    NSLog(@"Sending HTTP request - %@", requestUrl);
#endif
    return [self initWithRequestUrl:requestUrl httpMethod:httpMethod userName:userName userPassword:userPassword bodyText:bodyText httpHeaders:httpHeaders completeBlock:aCompleteBlock errorBlock:anErrorBlock];
}

#pragma mark - private
- (NSMutableURLRequest *)prepareRequest:(NSString *)endpoint httpMethod:(NSString *)httpMethod bodyText:(NSString *)bodyText httpHeaders:(NSDictionary *)httpHeaders {
    NSMutableURLRequest *request = [NSMutableURLRequest
									requestWithURL:[NSURL URLWithString:endpoint] ];
    
    NSString *authStr = nil;
    if (self.authUserName.length != 0 && self.authPassword != 0) {
        authStr = [NSString stringWithFormat:@"%@:%@", _authUserName, _authPassword ];
    }
    if (authStr) {
        NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:0]];
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    if (self.accept.length != 0) {
        [request setValue:self.accept forHTTPHeaderField:@"Accept"];
    }
    else {
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Accept"];
    }
    [request setHTTPMethod:httpMethod];
    if ([httpMethod compare:@"POST"] == NSOrderedSame && bodyText.length > 0) {
        [httpHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
        NSData *postData = [bodyText dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
#warning TODO accept NSData as method param instead of NSString       
        [request setHTTPBody:postData];
    }
    return request;
}

- (id)initWithRequestUrl:(NSString *)requestUrl userName:(NSString *)userName userPassword:(NSString *)userPassword bodyText:(NSString *)bodyText  httpHeaders:(NSDictionary *)httpHeaders completeBlock:(completeBlock_t)aCompleteBlock errorBlock:(errorBlock_t)anErrorBlock {
    
    return [self initWithRequestUrl:requestUrl httpMethod:@"GET" userName:userName userPassword:userPassword bodyText:bodyText httpHeaders:httpHeaders completeBlock:aCompleteBlock errorBlock:anErrorBlock];
}

- (id)initWithRequestUrl:(NSString *)requestUrl httpMethod:(NSString *)httpMethod userName:(NSString *)userName userPassword:(NSString *)userPassword bodyText:(NSString *)bodyText httpHeaders:(NSDictionary *)httpHeaders completeBlock:(completeBlock_t)aCompleteBlock errorBlock:(errorBlock_t)anErrorBlock {
    
    if ((self=[super init])) {
        data = [[NSMutableData alloc] init];
        self.authUserName = userName;
        self.authPassword = userPassword;
        
        completeBlock = [aCompleteBlock copy];
        errorBlock = [anErrorBlock copy];
        
        NSURLRequest *request = [self prepareRequest:requestUrl httpMethod:httpMethod bodyText:bodyText httpHeaders:httpHeaders];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
    
    return self;
}

- (id)initWithRequestUrl:(NSString *)requestUrl httpHeaders:(NSDictionary *)httpHeaders completeBlock:(completeBlock_t)aCompleteBlock errorBlock:(errorBlock_t)anErrorBlock {
        
    return [self initWithRequestUrl:requestUrl userName:nil userPassword:nil bodyText:nil httpHeaders:httpHeaders completeBlock:aCompleteBlock errorBlock:anErrorBlock];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [data setLength:0];
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        //If you need the response, you can use it here
        _httpStatus = httpResponse.statusCode;
        if (httpResponse.statusCode != 200) {
#ifdef HTTP_LOGGING
            NSLog(@"httpResponse.statusCode - %ld", (long)httpResponse.statusCode);
#endif
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)someData {
    [data appendData:someData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    completeBlock(data, _httpStatus);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    errorBlock(error);
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        if (YES) // ... user allows connection despite bad certificate ...
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end
