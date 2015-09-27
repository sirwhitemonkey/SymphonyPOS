
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
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        Response *response = [self getResponse:[self getMockData:@"checkConnection"]];
        persistenceManager.offline = false;
        [self.delegate apiCheckConnnectionResponse:response];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        persistenceManager.offline = true;
        [self setRequestOperationError:operation error:error];
    }];
    
    return operation;
    
}

























- (void) sync: (id)reference {
}

- (void) submitPayment:(id)reference invoice_no:(NSString*)invoice_no {
    
   if (MOCK_DATA) {
        Response *response;
        response = [self getResponse:[self getMockData:@"submitPayment"]];
       [self.delegate apiSubmitPaymentResponse:response];
       
        return;
    }
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",globalStore.my_custom_url,API_SUBMIT_PAYMENT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    NSDictionary *data = nil;
    NSData *jsonData = nil;
    NSString *paymentType = nil;
    NSString *payment = nil;
    NSString *cashSales = nil;
    NSString *customer = nil;
    NSString *carts = nil;
    
    // Customer
    data = [persistenceManager getDataStore:CUSTOMER];
    jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    customer = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    // Payment
    paymentType = [persistenceManager getDataStore:PAYMENT_TYPE];
    if ([paymentType isEqualToString:PAYMENT_CREDITCARD]) {
        payment = [persistenceManager getKeyChain:paymentType];
    
    } else if ([paymentType isEqualToString:PAYMENT_CASH]) {
        data = [persistenceManager getDataStore:payment];
        jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
        payment =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    }
    
    // CashSales
    data = [persistenceManager getDataStore:CASH_SALES];
    jsonData = [NSJSONSerialization dataWithJSONObject:data
                                               options:NSJSONWritingPrettyPrinted
                                                 error:nil];
    cashSales =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    // Carts
    NSArray *cartStores = [persistenceManager getCartStores];
    NSMutableArray *saleCarts = [NSMutableArray array];
    for (CartStore *cartStore in cartStores) {
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        CustomerStore *customerStore = [persistenceManager getCustomerStore:globalStore.customer_default_code];
        
        PriceListStore *priceListStore = [persistenceManager getPriceListByProductStore:customerStore.pricelist_code
                                                             product_code:cartStore.cartProduct.itemNo];
        [data setObject:cartStore.cart_code forKey:@"cart_code"];
        [data setObject:cartStore.qty forKey:@"qty"];
        [data setObject:customerStore.customer_code forKey:@"customer_code"];
        [data setObject:priceListStore.pricelist_code forKey:@"pricelist_code"];
        [data setObject:cartStore.cartProduct.itemNo forKey:@"itemNo"];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        [saleCarts addObject:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
        
    }
    carts = [saleCarts componentsJoinedByString:@","];

    
    [request setHTTPMethod:@"POST"];
    /*!
     * parameters:
     * token , the unique identifier returned from server
     * paymentType, the payment type used
     * customer, the customer details {name,email,phone ... etc.}
     * payment, the payment details {cash,eftpos,creditcard)
     * cashSales, the cash sales details {subtotals,salespercentagetax,grandtotals}
     * customer_code, the customer code used
     * carts, the carts details {cart_code,qty, product ... etc}
     */
    NSString *params = [NSString stringWithFormat:@"token=%@&paymentType=%@&customer=%@payment=%@&invoice_no=%@&cashSales=%@customer_code=%@&carts=%@",
                        [persistenceManager getKeyChain:APP_TOKEN],
                        paymentType,customer, payment, invoice_no,cashSales,globalStore.customer_default_code,carts];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        Response *response = (Response*)[self getResponse:responseObject];
        [self.delegate apiSubmitPaymentResponse:response];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setRequestOperationError:operation error:error];
        
    }];
    [operation start];
}

- (void) offlineSales:(id)reference {
    
    if (MOCK_DATA) {
        Response *response;
        response = [self getResponse:[self getMockData:@"offlineSales"]];
        
        [self.delegate apiOfflineSalesResponse:response];
        
        return;
    }
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",globalStore.my_custom_url,API_OFFLINE_SALES]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    // Carts
    NSArray *offlineSalesStores = [persistenceManager getOfflineSalesStore];
    NSMutableArray *offlineSales = [NSMutableArray array];
    for (OfflineSalesStore *offlineSalesStore in offlineSalesStores) {
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        [data setObject:offlineSalesStore.invoice_no forKey:@"invoice_no"];
        [data setObject:offlineSalesStore.carts forKey:@"carts"];
        [data setObject:offlineSalesStore.customer_code forKey:@"customer_code"];
        [data setObject:offlineSalesStore.payment_type forKey:@"payment_type"];

        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        [offlineSales addObject:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
        
    }
    NSString  *offlineSalesData = [offlineSales componentsJoinedByString:@","];
    
    
    [request setHTTPMethod:@"POST"];
    /*!
     * parameters:
     * token , the unique identifier returned from server
     * offlineSales, the offline sales details {invoice_no ... etc.}
     */
    NSString *params = [NSString stringWithFormat:@"token=%@&offlineSales=%@",
                        [persistenceManager getKeyChain:APP_TOKEN],offlineSalesData];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        Response *response = (Response*)[self getResponse:responseObject];
        
       [self.delegate apiOfflineSalesResponse:response];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setRequestOperationError:operation error:error];
        
    }];
    [operation start];
    
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

#pragma Private methods
- (void) setHeaders :(NSMutableURLRequest *) request{
    NSString *wsee = [CocoaWSSE headerWithUsername:[persistenceManager getKeyChain:APP_USER_IDENT] password:[persistenceManager getKeyChain:APP_USER_SECURITY]];
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
    }
    response.data = message;
    [self.delegate apiRequestError:error response:response];
}
@end
