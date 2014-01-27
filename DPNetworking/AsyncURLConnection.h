//
//  AsyncURLConnection.h
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

#import <Foundation/Foundation.h>

typedef void (^completeBlock_t)(NSData *data, NSUInteger httpStatusCode);
typedef void (^errorBlock_t)(NSError *error);

@interface AsyncURLConnection : NSObject
{
    NSMutableData *data;
    completeBlock_t completeBlock;
    errorBlock_t errorBlock;
}

/**
 Asynchronously performs an HTTP GET - invokes one of the blocks depending on the response to the request 
*/
- (id)requestUrl:(NSString *)requestUrl httpHeaders:(NSDictionary *)httpHeaders completeBlock:(completeBlock_t)aCompleteBlock errorBlock:(errorBlock_t)anErrorBlock;

// using Basic Auth
- (id)requestUrl:(NSString *)requestUrl userName:(NSString *)userName userPassword:(NSString *)userPassword httpHeaders:(NSDictionary *)httpHeaders completeBlock:(completeBlock_t)aCompleteBlock errorBlock:(errorBlock_t)anErrorBlock;

// with httpMethod - @"GET", @"POST" etc
- (id)requestUrl:(NSString *)requestUrl httpMethod:(NSString *)httpMethod bodyText:(NSString *)bodyText httpHeaders:(NSDictionary *)httpHeaders completeBlock:(completeBlock_t)aCompleteBlock errorBlock:(errorBlock_t)anErrorBlock;

// with httpMethod - @"GET", @"POST" etc and Basic Auth
- (id)requestUrl:(NSString *)requestUrl httpMethod:(NSString *)httpMethod userName:(NSString *)userName userPassword:(NSString *)userPassword bodyText:(NSString *)bodyText httpHeaders:(NSDictionary *)httpHeaders completeBlock:(completeBlock_t)aCompleteBlock errorBlock:(errorBlock_t)anErrorBlock;

// If HTTP Basic authentication optional parameters are non-empty strings, request will encode the URL with them.
@property (nonatomic, copy) NSString *authUserName; // HTTP Basic authentication optional parameter
@property (nonatomic, copy) NSString *authPassword; // HTTP Basic authentication optional parameter

@property (nonatomic, copy) NSString *accept; // Optional parameter to set the response type accepted (default is @"application/json")

@end
