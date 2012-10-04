//
//  CuthbertJuxtapositionAPIClient.m
//  Cuthbert
//
//  Created by Dan Nemeth on 7/26/12.
//  Copyright (c) 2012 Enterprise Slackers, LLC. All rights reserved.
//

#import "CuthbertJuxtapositionAPIClient.h"
#import "AFNetworking.h"

#define JuxtapositionAPIBaseURLString @"http://morning-escarpment-1668.herokuapp.com/"
#define ThiggyAPIToken @"50295f2e8822700200000002"  
#define JoseAPIToken @"50295f268822700200000001"

@implementation CuthbertJuxtapositionAPIClient

+ (CuthbertJuxtapositionAPIClient *)sharedClient {
    static CuthbertJuxtapositionAPIClient *__sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedClient = [[CuthbertJuxtapositionAPIClient alloc] initWithBaseURL: [NSURL URLWithString:JuxtapositionAPIBaseURLString]];
    });
    
    return __sharedClient;
}

- (CuthbertJuxtapositionAPIClient *) initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        //custom settings
        [self setDefaultHeader:@"x-api-token" value:ThiggyAPIToken];
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    }
    
    return self;
}

@end
