
#import "APIManager.h"


@interface APIManager()
@end

@implementation APIManager
@synthesize  delegate,batchOperation;

#pragma mark - api services

-(AFHTTPRequestOperation*) authSubmit{
    
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    
    if (MOCK_DATA) {
        Response *response;
        response = [self getResponse:[self getMockData:@"authSubmit"]];
        [self.delegate apiAuthSubmitResponse:response];
        return nil;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",globalStore.my_custom_url,API_AUTH_SUBMIT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [self setHeaders:request];
    [request setHTTPMethod:@"POST"];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [JSONResponseSerializerWithData serializer];
   
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         Response *response;
         response = (Response*)[self getResponse:responseObject];
        [self.delegate apiAuthSubmitResponse:response];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setRequestOperationError:operation error:error];
    }];
    return operation;
}

-(AFHTTPRequestOperation*) themes {

     GlobalStore *globalStore = [persistenceManager getGlobalStore];
    if (MOCK_DATA) {
        Response *response;
        response = [self getResponse:[self getMockData:@"themes"]];
        [self.delegate apiThemesResponse:response];
        return nil;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",globalStore.my_custom_url,API_SETTING_THEMES]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [self setHeaders:request];
    [request setHTTPMethod:@"GET"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        Response *response = (Response*)[self getResponse:responseObject];
        [self.delegate apiThemesResponse:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setRequestOperationError:operation error:error];
    }];
    return operation;
}

-(AFHTTPRequestOperation*) dataDefaults {
    
     GlobalStore *globalStore = [persistenceManager getGlobalStore];
     if (MOCK_DATA) {
         Response *response;
         response = [self getResponse:[self getMockData:@"dataDefaults"]];
         [self.delegate apiDataDefaultsResponse:response];
         return nil;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",globalStore.my_custom_url,API_SETTING_DATA_DEFAULTS]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [self setHeaders:request];
    [request setHTTPMethod:@"GET"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        Response *response = (Response*)[self getResponse:responseObject];
        [self.delegate apiDataDefaultsResponse:response];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       [self setRequestOperationError:operation error:error];
    }];
    return operation;
}

-(AFHTTPRequestOperation*) getProducts:(int)page{
  
    if (MOCK_DATA) {
        Response *response;
        response = [self getResponse:[self getMockData:@"getProducts"]];
        [self.delegate apiProductsResponse:response];
        return nil;
    }

    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    NSString *params = [NSString stringWithFormat:@"date_last_updated=%@&page=%d&limit=%d",
                        [persistenceManager getKeyChain:SYNC_DATE_LAST_UPDATED],page,PAGE_LIMIT];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@",globalStore.my_custom_url,API_PRODUCTS,params]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [self setHeaders:request];
    [request setHTTPMethod:@"GET"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        Response *response = [self getResponse:responseObject];
        [self.delegate apiProductsResponse:response];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       [self setRequestOperationError:operation error:error];
    }];
    return operation;
}

-(AFHTTPRequestOperation*) getCustomers:(int)page{
    
    if (MOCK_DATA) {
        Response *response;
        response = [self getResponse:[self getMockData:@"getCustomers"]];
        [self.delegate apiCustomersResponse:response];
        return nil;
    }
    
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    NSString *params = [NSString stringWithFormat:@"date_last_updated=%@&page=%d&limit=%d",
                        [persistenceManager getKeyChain:SYNC_DATE_LAST_UPDATED],page,PAGE_LIMIT];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@",globalStore.my_custom_url,API_CUSTOMERS,params]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [self setHeaders:request];
    [request setHTTPMethod:@"GET"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        Response *response = [self getResponse:responseObject];
        [self.delegate apiCustomersResponse:response];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setRequestOperationError:operation error:error];
    }];
    return operation;
}

-(AFHTTPRequestOperation*) getPriceLists:(int)page{
    
    if (MOCK_DATA) {
        Response *response;
        response = [self getResponse:[self getMockData:@"getPriceLists"]];
        [self.delegate apiPriceListsResponse:response];
        return nil;
    }
    
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    NSString *params = [NSString stringWithFormat:@"date_last_updated=%@&page=%d&limit=%d",
                        [persistenceManager getKeyChain:SYNC_DATE_LAST_UPDATED],page,PAGE_LIMIT];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@",globalStore.my_custom_url,API_PRICELISTS,params]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [self setHeaders:request];
    [request setHTTPMethod:@"GET"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        Response *response = [self getResponse:responseObject];
        [self.delegate apiPriceListsResponse:response];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setRequestOperationError:operation error:error];
    }];
    return operation;
}

-(AFHTTPRequestOperation*) getPrices:(int)page{
    
    if (MOCK_DATA) {
        Response *response;
        response = [self getResponse:[self getMockData:@"getPrices"]];
        [self.delegate apiPricesResponse:response];
        return nil;
    }
    
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    NSString *params = [NSString stringWithFormat:@"date_last_updated=%@&page=%d&limit=%d",
                        [persistenceManager getKeyChain:SYNC_DATE_LAST_UPDATED],page,PAGE_LIMIT];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@",globalStore.my_custom_url,API_PRICES,params]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [self setHeaders:request];
    [request setHTTPMethod:@"GET"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        Response *response = [self getResponse:responseObject];
        [self.delegate apiPricesResponse:response];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setRequestOperationError:operation error:error];
    }];
    return operation;
}


- (AFHTTPRequestOperation*) checkConnection {
    
    if (MOCK_DATA) {
        Response *response;
        response = [self getResponse:[self getMockData:@"checkConnection"]];
        persistenceManager.offline = false;
       [self.delegate apiCheckConnnectionResponse:response];
        return nil;
    }
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",globalStore.my_custom_url,API_CHECK_CONNECTION]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [self setHeaders:request];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        Response *response = [self getResponse:responseObject];
        persistenceManager.offline = false;
        [self.delegate apiCheckConnnectionResponse:response];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setRequestOperationError:operation error:error];
    }];
    
    return operation;
    
}

- (AFHTTPRequestOperation*) submitTransactions:(NSString *)transactions {
    
    if (MOCK_DATA) {
        Response *response;
        response = [self getResponse:[self getMockData:@"submitTransactions"]];
        [self.delegate apiSubmitTransactionsResponse:response];
        return nil;
    }
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",globalStore.my_custom_url,API_SUBMIT_TRANSACTIONS]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [self setHeaders:request];
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:[transactions dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        Response *response = (Response*)[self getResponse:responseObject];
        
        [self.delegate apiSubmitTransactionsResponse:response];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setRequestOperationError:operation error:error];
        
    }];
    return operation;
}


- (void) syncImage:(UIImageView*) refImageView url:(NSString *)url {
    
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:url]];
    UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
    
    __weak UIImageView *imageView = refImageView;
    
    [refImageView setImageWithURLRequest:request
                     placeholderImage:placeholderImage
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  
                                  imageView.image = image;
                                  [imageView setNeedsLayout];
                              } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                  DebugLog(@"failed loading: %@", error);
                              }];
}



#pragma Private methods
/*!
 * APIManager de-serialising json response object.
 */
- (Response*) getResponse:(NSDictionary*)responseObject {
    NSError *error = nil;
    Response *response  =[MTLJSONAdapter modelOfClass:[Response class]
                                   fromJSONDictionary:responseObject
                                                error:&error];
    
    if (error) {
        DebugLog(@"getResponse -> error -> %@",[error description]);
        response = nil;
    }
    return response;
}

/*!
 * APIManager sample mocking of data.
 */
- (id) getMockData:(NSString*)api {
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:api
                                                         ofType:@"json"];
    NSData *dataFromFile = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:dataFromFile
                                                         options:kNilOptions
                                                           error:&error];
    
    if (error != nil) {
        DebugLog(@"getMockData error:%@",[error description]);
        return nil;
    }
    
    return data;
}

- (void) setHeaders :(NSMutableURLRequest *) request{
    NSString *wsee = [CocoaWSSE headerWithUsername:[persistenceManager getKeyChain:USER_IDENT] password:[persistenceManager getKeyChain:USER_SECURITY]];
    DebugLog(@"wsee ->%@",wsee);
    [request setValue:wsee forHTTPHeaderField:@"X-WSSE"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
}

- (NSString*) getError:(Response*)response {
    NSString *message=nil;
    if (response!=nil && [response.responseCode integerValue] == HTTP_STATUS_UNAUTHORIZED) {
        message = UNAUTHORIZED_USER;
    } else {
        message = SERVER_ERROR;
    }
    return message;
}

- (void) setRequestOperationError:(AFHTTPRequestOperation*)operation error:(NSError *)error {
    Response *response;
    id jsonString = error.userInfo[JSONResponseSerializerWithDataKey];
    NSString *message = SERVER_ERROR;
     if (jsonString) {
        id responseObject = [NSJSONSerialization JSONObjectWithData:
                             [jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:0 error:nil];
        response = (Response*)[self getResponse:responseObject];
        message = [self getError:response];
         
     } else {
         response = [[Response alloc]init];
         response.responseCode = [NSNumber numberWithInt:HTTP_STATUS_SERVICE_UNAVAILABLE];
         message = SERVER_ERROR;
         persistenceManager.offline = true;
     }
    response.data = message;
    [self.delegate apiRequestError:error response:response];
}
@end
