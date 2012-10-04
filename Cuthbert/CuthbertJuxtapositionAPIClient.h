//
//  CuthbertJuxtapositionAPIClient.h
//  Cuthbert
//
//  Created by Dan Nemeth on 7/26/12.
//  Copyright (c) 2012 Enterprise Slackers, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface CuthbertJuxtapositionAPIClient : AFHTTPClient

+ (CuthbertJuxtapositionAPIClient *)sharedClient;

@end
