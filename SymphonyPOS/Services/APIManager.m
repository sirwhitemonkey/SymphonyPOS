
#import "APIManager.h"


@interface APIManager()
/*!
 * APIManager vfbViewController,  the visual presentation.
 */
@property(nonatomic,strong) VisualFeedBackViewController *vfbViewController;

/*!
 * APIManager reference, the reference view controller object.
 */
@property (weak) id reference;

@end

@implementation APIManager
@synthesize  delegate;
@synthesize vfbViewController = _vfbViewController;
@synthesize reference = _reference;

#pragma mark - api services

-(void) login: (id)reference username:(NSString *)username password:(NSString *)password  {
    
    _reference = reference;
    
    [self visualFeedback:@"Authenticating ..." hide:NO withCallBack:nil];
    
    if (MOCK_DATA) {
        Response *response;
        response = [self getResponse:[self getMockData:@"login"]];
        
        [self visualFeedback:nil hide:YES withCallBack: ^{
           [self.delegate apiLoginResponse:response];
        }];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",API_URL,API_LOGIN]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    /**
     * parameters:
     * username , the merchant's account
     * password, the merchant's password
     */
    NSString *params = [NSString stringWithFormat:@"username=%@&password=%@",username,password];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         Response *response = (Response*)[self getResponse:responseObject];
      
        [self visualFeedback:nil hide:YES withCallBack: ^{
            [self.delegate apiLoginResponse:response];
        }];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self visualFeedback:nil hide:YES withCallBack: ^ {
            [sharedServices showMessage:reference message:[error description] error:YES withCallBack: ^ {
                [self.delegate apiRequestError:error];
            }];
        }];
      
    }];
    [operation start];
    
}

- (void) submitAuthorisation:(id)reference {
    _reference = reference;
    
    [self visualFeedback:@"Authorising ..." hide:NO withCallBack:nil];
    
    if (MOCK_DATA) {
        Response *response;
        response = [self getResponse:[self getMockData:@"submitAuthorisation"]];
        
        [self visualFeedback:nil hide:YES withCallBack:^ {
            [self.delegate apiSubmitAuthorisationResponse:response];
        }];
        
        return;
    }
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",globalStore.my_custom_url,API_SUBMIT_AUTHORISATION]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    /*!
     * parameters:
     * token , the unique identifier returned from server
     * passkey, the unique pass key for the encryption/decryption
     */
    NSString *params = [NSString stringWithFormat:@"token=%@&passkey=%@",
                        [persistenceManager getKeyChain:APP_TOKEN],
                        [persistenceManager getKeyChain:PASSKEY]];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        Response *response = (Response*)[self getResponse:responseObject];
        
        [self visualFeedback:nil hide:YES withCallBack:^ {
            [self.delegate apiSubmitAuthorisationResponse:response];
        }];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self visualFeedback:nil hide:YES withCallBack: ^ {
            [sharedServices showMessage:reference message:[error description] error:YES withCallBack: ^ {
                [self.delegate apiRequestError:error];
            }];
        }];
        
        
    }];
    [operation start];
    
}

- (void) sync: (id)reference {
    _reference = reference;
    
    [self visualFeedback:@"Synchronising ..." hide:NO withCallBack:nil];
    
     if (MOCK_DATA) {
        Response *response;
        response = [self getResponse:[self getMockData:@"sync"]];
       
         [self visualFeedback:nil hide:YES withCallBack:^ {
           [self.delegate apiSyncResponse:response];
        }];
         
        return;
    }
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",globalStore.my_custom_url,API_SYNC]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    /*!
     * parameters:
     * token , the unique identifier returned from server
     * date_last_updated, the date last updated for the sync validation
     */
    NSString *params = [NSString stringWithFormat:@"token=%@&date_last_updated=%@",
                        [persistenceManager getKeyChain:APP_TOKEN],
                        [persistenceManager getKeyChain:API_SYNC_DATE_LAST_UPDATED]];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        Response *response = (Response*)[self getResponse:responseObject];
        
        [self visualFeedback:nil hide:YES withCallBack:^ {
            [self.delegate apiSyncResponse:response];
        }];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self visualFeedback:nil hide:YES withCallBack: ^ {
            [sharedServices showMessage:reference message:[error description] error:YES withCallBack: ^ {
                [self.delegate apiRequestError:error];
            }];
        }];

        
    }];
    [operation start];
   
}

- (void) submitPayment:(id)reference invoice_no:(NSString*)invoice_no {
    _reference = reference;
    
    [self visualFeedback:@"Processing payment ..." hide:NO withCallBack:nil];
    
    if (MOCK_DATA) {
        Response *response;
        response = [self getResponse:[self getMockData:@"submitPayment"]];
        
        [self visualFeedback:nil hide:YES withCallBack:^ {
            [self.delegate apiSubmitPaymentResponse:response];
        }];
        
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
                                                             product_code:cartStore.cartProduct.product_code];
        [data setObject:cartStore.cart_code forKey:@"cart_code"];
        [data setObject:cartStore.qty forKey:@"qty"];
        [data setObject:customerStore.customer_code forKey:@"customer_code"];
        [data setObject:priceListStore.pricelist_code forKey:@"pricelist_code"];
        [data setObject:cartStore.cartProduct.product_code forKey:@"product_code"];
        
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
        
        [self visualFeedback:nil hide:YES withCallBack:^ {
            [self.delegate apiSubmitPaymentResponse:response];
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self visualFeedback:nil hide:YES withCallBack: ^ {
            [sharedServices showMessage:reference message:[error description] error:YES withCallBack: ^ {
                [self.delegate apiRequestError:error];
            }];
        }];
        
        
    }];
    [operation start];
    
}

- (void) offlineSales:(id)reference {
    
    _reference = reference;
    
    [self visualFeedback:@"Processing offline sales ..." hide:NO withCallBack:nil];
    
    if (MOCK_DATA) {
        Response *response;
        response = [self getResponse:[self getMockData:@"offlineSales"]];
        
        [self visualFeedback:nil hide:YES withCallBack:^ {
            [self.delegate apiOfflineSalesResponse:response];
        }];
        
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
        
        [self visualFeedback:nil hide:YES withCallBack:^ {
            [self.delegate apiOfflineSalesResponse:response];
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self visualFeedback:nil hide:YES withCallBack: ^ {
            [sharedServices showMessage:reference message:[error description] error:YES withCallBack: ^ {
                [self.delegate apiRequestError:error];
            }];
        }];
        
        
    }];
    [operation start];
    
}


- (void) checkConnection:(id)reference {
    
    _reference = reference;
    
    [self visualFeedback:@"Checking server connection ..." hide:NO withCallBack:nil];
    
    if (MOCK_DATA) {
        Response *response;
        response = [self getResponse:[self getMockData:@"checkConnection"]];
        persistenceManager.offline = false;
        [self visualFeedback:nil hide:YES withCallBack:^ {
            [self.delegate apiCheckConnnectionResponse:response];
        }];
        
        return;
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
        [self visualFeedback:nil hide:YES withCallBack:^ {
            [self.delegate apiCheckConnnectionResponse:response];
        }];
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        persistenceManager.offline = true;
        [self.delegate apiRequestError:error];
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



-(void) getProducts:(id)reference page:(int)page limit:(int)limit {
 
    _reference = reference;
    
    [self visualFeedback:@"Synchronising products ..." hide:NO withCallBack:nil];
   
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
   
    NSString *params = [NSString stringWithFormat:@"page=%d&limit=%d",page,limit];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@",globalStore.my_custom_url,API_PRODUCTS,params]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    DebugLog(@"%@",[CocoaWSSE headerWithUsername:@"ronaldo" password:@"b1495fc2427e37dda908c7c3d230046f55883286"]);
    [request setValue:[CocoaWSSE headerWithUsername:@"ronaldo" password:@"b1495fc2427e37dda908c7c3d230046f55883286"] forHTTPHeaderField:@"X-WSSE"];
    [request setHTTPMethod:@"GET"];
    /*!
     * parameters:
     * page , page position
     * limit, no. of records retrieved
     */
    //request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DebugLog(@"--->%@",responseObject);
        
        Response *response = [self getResponse:responseObject];
        [self visualFeedback:nil hide:YES withCallBack:^ {
            [self.delegate apiProductsResponse:response];
        }];
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self visualFeedback:nil hide:YES withCallBack: ^ {
            [sharedServices showMessage:reference message:[error description] error:YES withCallBack: ^ {
                [self.delegate apiRequestError:error];
            }];
        }];
    }];
    [operation start];
    
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
    }
    return response;
    
}

/*!
 * APIManager visual presentation.
 */
- (void) visualFeedback:(NSString*) message  hide:(BOOL)hide
           withCallBack:(void (^)(void))callbackBlock {
    
    if (!hide) {
        _vfbViewController = (VisualFeedBackViewController*)[persistenceManager getView:@"VisualFeedBackViewController"];
        _vfbViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [_vfbViewController initialise:YES message:message error:NO];
        [_vfbViewController setModalPresentationStyle:UIModalPresentationOverFullScreen];
        [_reference presentViewController:_vfbViewController animated:YES completion:^ {
            if (callbackBlock!=nil) {
                callbackBlock();
            }
        }];
       } else {
        if (_vfbViewController) {
            [_vfbViewController dismissViewControllerAnimated:NO completion:^ {
                if (callbackBlock!=nil) {
                    callbackBlock();
                }
            }];
            
        }
    }
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



@end
