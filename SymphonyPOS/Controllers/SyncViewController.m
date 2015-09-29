
#import "SyncViewController.h"

@interface SyncViewController ()
@property (nonatomic,strong) APIManager *apiManager;
@end

@implementation SyncViewController
@synthesize delegate,settings;
@synthesize apiManager = _apiManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    _apiManager = [[APIManager alloc] init];
    _apiManager.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - APIManager
- (void)apiRequestError:(NSError *)error response:(Response *)response {
    DebugLog(@"apiRequestError -> %@,%@", error,response);
    if ([response.responseCode integerValue] == HTTP_STATUS_SERVICE_UNAVAILABLE) {
        [service hideMessage:^ {
            [service showMessage:self loader:NO message:(NSString*)response.data error:YES waitUntilCompleted:NO withCallBack:^ {
                [self.delegate syncDidError:self];
            }];
        }];
    }
}

- (void) apiProductsResponse:(Response *)response {
    [persistenceManager syncProducts:_apiManager response:response completedCallback:^ {
        [service hideMessage:^ {
            // Sync customers
            [service showMessage:self loader:YES message:@"Synchronising customers ..." error:NO
              waitUntilCompleted:YES withCallBack:^ {
                  _apiManager.batchOperation = true;
                  AFHTTPRequestOperation *syncCustomers = [_apiManager getCustomers:0];
                  if (syncCustomers) {
                      [syncCustomers start];
                  }
              }];
            
        }];
    }];
}

- (void) apiCustomersResponse:(Response *)response {
    [persistenceManager syncCustomers:_apiManager response:response completedCallback:^ {
        [service hideMessage:^ {
            // Sync pricelists
            [service showMessage:self loader:YES message:@"Synchronising pricelists ..." error:NO
              waitUntilCompleted:YES withCallBack:^ {
                  _apiManager.batchOperation = true;
                  AFHTTPRequestOperation *syncPriceLists = [_apiManager getPriceLists:0];
                  if (syncPriceLists) {
                      [syncPriceLists start];
                  }
              }];
        }];
    }];
}

- (void) apiPriceListsResponse:(Response *)response {
    [persistenceManager syncPriceLists:_apiManager response:response completedCallback:^ {
        [service hideMessage:^ {
            // Sync prices
            [service showMessage:self loader:YES message:@"Synchronising prices ..." error:NO
              waitUntilCompleted:YES withCallBack:^ {
                  _apiManager.batchOperation = true;
                  AFHTTPRequestOperation *syncPrices = [_apiManager getPrices:0];
                  if (syncPrices) {
                      [syncPrices start];
                  }
              }];
        }];
    }];
}

- (void) apiPricesResponse:(Response *)response {
    [persistenceManager syncPrices:_apiManager response:response completedCallback:^ {
        
        [service hideMessage:^ {
            
            if (self.settings) {
                _apiManager.batchOperation = true;
                [service showMessage:self loader:YES message:@"Updating settings ..." error:NO
                  waitUntilCompleted:YES withCallBack:^ {
                      
                      AFHTTPRequestOperation *themes = [_apiManager themes];
                      AFHTTPRequestOperation *dataDefaults = [_apiManager dataDefaults];
                      
                      if (themes && dataDefaults) {
                          NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:@[themes,dataDefaults] progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                              DebugLog(@"%lu of %lu complete",(unsigned long)numberOfFinishedOperations,(unsigned long)totalNumberOfOperations);
                              
                          } completionBlock:^(NSArray *operations) {
                              _apiManager.batchOperation = false;
                              DebugLog(@"All operations in batch complete");
                              [persistenceManager updateSettingsBundle];
                              [service hideMessage:^ {
                                  [persistenceManager setKeyChain:SYNC_DATE_LAST_UPDATED value:[persistenceManager getDataStore:SYNC_DATE_LAST_UPDATED]];
                                  [self.delegate syncDidCompleted:self];
                              }];
                          }];
                          [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
                      }
                  }];
            } else {
                [self.delegate syncDidCompleted:self];
            }
            
        }];
    }];
}

- (void)apiThemesResponse:(Response *)response {
    DebugLog(@"apiThemesResponse -> %@", response);
    
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:(NSDictionary*)response.data
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    globalStore.themes = jsonString;
    [persistenceManager saveContext];
}

- (void) apiDataDefaultsResponse:(Response *)response {
    DebugLog(@"apiDataDefaultsResponse -> %@", response);
    
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    DataDefaults *dataDefaults = [MTLJSONAdapter modelOfClass:DataDefaults.class fromJSONDictionary:(NSDictionary*)response.data error:nil];
    globalStore.sales_percentage_tax = dataDefaults.sales_percentage_tax;
    globalStore.last_order_number = dataDefaults.last_order_number;
    globalStore.prefix = dataDefaults.prefix;
    globalStore.prefix_number_length = dataDefaults.prefix_number_length;
    globalStore.customer_default_code =  dataDefaults.customer_default_code;
    globalStore.customer_default_code_copy =dataDefaults.customer_default_code;
    if ([globalStore.days_sync_interval integerValue] == 0) {
        globalStore.days_sync_interval = [NSNumber numberWithInt:30];
    }
    [persistenceManager saveContext];
}


#pragma  mark - Public methods

- (void) sync {
    // Sync products
    [service showMessage:self loader:YES message:@"Synchronising products ..." error:NO
      waitUntilCompleted:YES withCallBack:^ {
          _apiManager.batchOperation = true;
          AFHTTPRequestOperation *syncProducts = [_apiManager getProducts:0];
          if (syncProducts) {
              [syncProducts start];
          }
      }];
}



@end
