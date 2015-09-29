
#import "PersistenceManager.h"

@interface PersistenceManager()
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,strong) NSMutableDictionary *dataStore;
@property (nonatomic,strong) NSMutableArray *responseData;

- (NSURL *)applicationDocumentsDirectory;

@end

@implementation PersistenceManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize dataStore = _dataStore;
@synthesize responseData = _responseData;
@synthesize offline;

+(PersistenceManager*)sharedInstance {
    static dispatch_once_t oncePredicate;
    static PersistenceManager *_sharedInstance;
    dispatch_once(&oncePredicate,^{
        _sharedInstance=[[PersistenceManager alloc]initWithData];

    });
    return _sharedInstance;
}

- (id) initWithData {
    self = [super init];
    if (self) {
        _dataStore = [[NSMutableDictionary alloc]init];
    }
    return self;
}


#pragma mark - Public methods - common

- (void) setKeyChain:(NSString *)key value:(NSString *)value {
 
    DebugLog(@"storeToKeyChain");
    [KeychainWrapper createKeychainValue:value forIdentifier:key];
}

- (NSString*) getKeyChain:(NSString *)key {
    DebugLog(@"getKeyChain");
    return [KeychainWrapper keychainStringFromMatchingIdentifier:key];
}

- (void)removeFromKeyChain:(NSString *)key {
    [KeychainWrapper deleteItemFromKeychainWithIdentifier:key];
}

- (void) setDataStore:(NSString *)key value:(id)value {
    [_dataStore  setObject:value forKey:key];
}

- (void) removeDataStore: (NSString*)key {
    [_dataStore removeObjectForKey:key];
}

-(id) getDataStore:(NSString *)key {
    return [_dataStore objectForKey:key];
}

- (UIViewController*) getView:(NSString*)identifier {
     UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:identifier];
}

- (void) updateSettingsBundle {
    
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        DebugLog(@"Could not find Settings.bundle");
        return;
    }
    
    
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    DebugLog(@"globalStore ->%@",globalStore);
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            id value = [prefSpecification objectForKey:@"DefaultValue"];
            
            if ([key isEqualToString:@"terminal_name"]) {
                if ([service isEmptyString:value]) {
                    if (globalStore.terminal_name != nil) {
                        value = globalStore.terminal_name;
                    }
                }
                globalStore.terminal_name = value;
            }
            else  if ([key isEqualToString:@"terminal_code"]) {
                if ([service isEmptyString:value]) {
                    if (globalStore.terminal_code != nil) {
                        value = globalStore.terminal_code;
                    }
                }
                globalStore.terminal_code = value;
            }
            else  if ([key isEqualToString:@"customer_default"]) {
                if (globalStore.customer_default_code != nil) {
                    value = globalStore.customer_default_code;
                }
            }
            else  if ([key isEqualToString:@"prefix"]) {
                if (globalStore.prefix != nil) {
                    value = globalStore.prefix;
                }
            }
            else  if ([key isEqualToString:@"prefix_number_length"]) {
                if (globalStore.prefix_number_length != nil) {
                    value = [globalStore.prefix_number_length stringValue];
                }
            }
            else  if ([key isEqualToString:@"sales_percentage_tax"]) {
                if (globalStore.sales_percentage_tax != nil) {
                    value = [globalStore.sales_percentage_tax stringValue];
                }
            }
            else  if ([key isEqualToString:@"last_order_number"]) {
                if (globalStore.last_order_number != nil) {
                    value = [globalStore.last_order_number stringValue];
                }
            }
            else  if ([key isEqualToString:@"syncEvent"]) {
                if (globalStore.sync_event != nil) {
                    value = globalStore.sync_event;
                }
            }
            else  if ([key isEqualToString:@"logoutEvent"]) {
                if (globalStore.logout_event!= nil) {
                    value = globalStore.logout_event;
                }
            }
            else  if ([key isEqualToString:@"qtyEvent"]) {
                if (globalStore.qty_event!= nil) {
                    value = globalStore.qty_event;
                }
            }
            else  if ([key isEqualToString:@"days_sync_interval"]) {
                if (globalStore.days_sync_interval!= nil) {
                    value = [globalStore.days_sync_interval stringValue];
                }
            }
            else if ([key isEqualToString:@"scanMode"]) {
                if ([persistenceManager getDataStore:SCAN_MODE] !=nil) {
                    value = [persistenceManager getDataStore:SCAN_MODE];
                }
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        }
    }
    [self saveContext];
}


#pragma mark - Public methods - coredata
- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

-(void)removeEntityObject:(NSManagedObject *)managedObject {
    [[self managedObjectContext]deleteObject:managedObject];
    [self saveContext];
}

- (void)setPriceListStore:(PriceList*)pricelist {
    PriceListStore *pricelistStore = [self getPriceListStore:pricelist.code];
    if (!pricelistStore) {
        pricelistStore = [NSEntityDescription insertNewObjectForEntityForName:@"PriceListStore" inManagedObjectContext:[self managedObjectContext]];
    }
    pricelistStore.identifier = pricelist.identifier;
    pricelistStore.code = pricelist.code;
    pricelistStore.desc = pricelist.desc;
    [self saveContext];
    
}

- (PriceListStore*) getPriceListStore:(NSString*)code {
    NSManagedObjectContext *context = [self managedObjectContext];
    code=[[code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PriceListStore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"code = \"%@\"",code]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count>0) {
        return [results objectAtIndex:0];
    }
    return nil;
}


- (void) setCustomerStore:(Customer*)customer {
    CustomerStore *customerStore = [self getCustomerStore:customer.code];
    if (!customerStore) {
        customerStore = [NSEntityDescription insertNewObjectForEntityForName:@"CustomerStore" inManagedObjectContext:[self managedObjectContext]];
    }
    customerStore.identifier = customer.identifier;
    customerStore.code = customer.code;
    customerStore.address1 = customer.address1;
    customerStore.address2 = customer.address2;
    customerStore.address3 = customer.address3;
    customerStore.address4 = customer.address4;
    customerStore.currency = customer.currency;
    customerStore.email = customer.email;
    customerStore.group = customer.group;
    customerStore.name = customer.name;
    customerStore.priceCode = customer.priceCode;
    customerStore.status = customer.status;
    customerStore.taxGroup = customer.taxGroup;
    
    [self saveContext];

}

- (CustomerStore*) getCustomerStore:(NSString*)code {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CustomerStore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"code = \"%@\"",code]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count>0) {
        return [results objectAtIndex:0];
    }
    return nil;

}

- (NSArray*) getCustomerStores:(NSString*)searchString {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fectchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"CustomerStore"
                                                         inManagedObjectContext:context];
    [fectchRequest setEntity: entityDescription];
    [fectchRequest setFetchBatchSize:100];
    
    NSSortDescriptor *sortDescription = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray * sortDescriptionArray = [[NSArray alloc] initWithObjects: sortDescription, nil];
    [fectchRequest setSortDescriptors: sortDescriptionArray];
    NSError *error = nil;
    
    NSArray *results = [context executeFetchRequest:fectchRequest error:&error];
    
    if ([service isEmptyString:searchString]) {
        return results;
    }
    
    if (results.count > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS %@ ", searchString];
        results=[NSMutableArray arrayWithArray:[results filteredArrayUsingPredicate:predicate]];
    }
    return results;
}

- (GlobalStore*) getGlobalStore {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GlobalStore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    GlobalStore *globalStore;
    if (results.count>0) {
        globalStore = [results objectAtIndex:0];
    } else {
       globalStore = [NSEntityDescription insertNewObjectForEntityForName:@"GlobalStore"
                                                   inManagedObjectContext:[self managedObjectContext]];
        
        //Testing only
        globalStore.my_custom_url = API_URL;
        globalStore.my_custom_logo = CUSTOM_CLIENT_LOGO;
    }
    DebugLog(@"getGlobalStore->%@",globalStore);
    return globalStore;
 
}

- (void)setProductStore:(Product*)product {

    ProductStore *productStore = [self getProductStore:product.itemNo];
    if (!productStore) {
        productStore = [NSEntityDescription insertNewObjectForEntityForName:@"ProductStore"
                                                     inManagedObjectContext:[self managedObjectContext]];
    }
    productStore.identifier = product.identifier;
    productStore.inStock  = [NSNumber numberWithBool:product.inStock];
    productStore.notActive = [NSNumber numberWithBool:product.notActive];
    productStore.image_url = product.image_url;
    productStore.stockUnit = product.stockUnit;
    productStore.desc = product.desc;
    productStore.upcCode = product.upcCode;
    productStore.itemNo = product.itemNo;
    [self saveContext];
}

- (ProductStore*)getProductStore:(NSString*)itemNo {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProductStore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setFetchLimit:1];
    request.entity = entity;
    request.fetchBatchSize = 1;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"itemNo = \"%@\"",itemNo]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count>0)
        return [results objectAtIndex:0];
    
    return nil;
}

- (ProductStore*)getProductStoreByUpcCode:(NSString *)upcCode {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProductStore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"upcCode =[cd] \"%@\"",upcCode]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count>0)
        return [results objectAtIndex:0];
    
    return nil;

}

- (NSArray*)getProductStores: (NSString*) searchString {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fectchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ProductStore"
                                                         inManagedObjectContext:context];
    [fectchRequest setEntity: entityDescription];
    [fectchRequest setFetchBatchSize:100];
    
    NSSortDescriptor *sortDescription = [[NSSortDescriptor alloc] initWithKey:@"desc" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray * sortDescriptionArray = [[NSArray alloc] initWithObjects: sortDescription, nil];
    [fectchRequest setSortDescriptors: sortDescriptionArray];
    NSError *error = nil;
    
    NSArray *results = [context executeFetchRequest:fectchRequest error:&error];
    
    if ([service isEmptyString:searchString]) {
        return results;
    }
    
    if (results.count > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.desc CONTAINS %@", searchString];
        results=[NSMutableArray arrayWithArray:[results filteredArrayUsingPredicate:predicate]];
    }
    return results;
}

- (void)setCartStore:(NSNumber*)qty productStore:(ProductStore*)productStore {
   
    CartStore *cartStore = [NSEntityDescription insertNewObjectForEntityForName:@"CartStore" inManagedObjectContext:[self managedObjectContext]];
    cartStore.cart_code = [self newUUID];
    cartStore.qty = qty;
    cartStore.cartProduct =productStore;
    [productStore addProductCartObject:cartStore];
    [self saveContext];
}

- (void)updateCartStore: (NSString*)cart_code qty:(NSNumber*)qty {
    CartStore *cartStore = [self getCartStore:cart_code];
    if (cartStore) {
        cartStore.qty = qty;
        [self saveContext];
    }
}

- (void)removeCartStore:(NSString*)cart_code {
    CartStore *cartStore = [self getCartStore:cart_code];
    if (cartStore) {
        [self removeEntityObject:cartStore];
    }
}

- (CartStore*)getCartStore:(NSString*)cart_code {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CartStore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"cart_code =[cd] \"%@\"",cart_code]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count>0) {
        return [results objectAtIndex:0];
    }
    return nil;
}

- (CartStore*)getCartByProductStore:(NSString*)itemNo {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CartStore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"cartProduct.itemNo =[cd] \"%@\"",itemNo]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count>0) {
        return [results objectAtIndex:0];
    }
    return nil;
}

- (NSArray*)getCartStores {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fectchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"CartStore"
                                                         inManagedObjectContext:context];
    [fectchRequest setEntity: entityDescription];
    
    NSSortDescriptor *sortDescription = [[NSSortDescriptor alloc] initWithKey:@"cartProduct.desc" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray * sortDescriptionArray = [[NSArray alloc] initWithObjects: sortDescription, nil];
    [fectchRequest setSortDescriptors: sortDescriptionArray];
    NSError *error = nil;
    
    NSArray *results = [context executeFetchRequest:fectchRequest error:&error];
    return results;
}

- (void)setPriceStore:(Price *)price {

    PriceStore *priceStore = [self getPriceStore: price.identifier];
    if (!priceStore) {
        priceStore = [NSEntityDescription insertNewObjectForEntityForName:@"PriceStore"
                                                               inManagedObjectContext:[self managedObjectContext]];
    }
    priceStore.identifier = price.identifier;
    priceStore.priceListCode = price.priceListCode;
    priceStore.itemNo = price.itemNo;
    priceStore.unitPrice = price.unitPrice;
    priceStore.currency = price.currency;
    [self saveContext];
}

- (PriceStore*)getPriceStore:(NSNumber*)identifier {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PriceStore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setFetchLimit:1];
    request.entity = entity;
    request.fetchBatchSize = 1;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"identifier = \"%ld\"", (long)[identifier integerValue]]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count>0)
        return [results objectAtIndex:0];
    
    return nil;
    
}

- (PriceStore*) getPriceStore:(NSString *)code itemNo:(NSString *)itemNo {
 
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PriceStore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setFetchLimit:1];
    request.entity = entity;
    request.fetchBatchSize = 1;
    request.predicate = [NSPredicate predicateWithFormat:
                         [NSString stringWithFormat:@"priceListCode = \"%@\" AND itemNo = \"%@\"",code,itemNo]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count>0)
        return [results objectAtIndex:0];
    
    return nil;
    
}

- (void) setOfflineSalesStore:(NSString*)invoice_no {
    OfflineSalesStore *offlineSalesStore = [NSEntityDescription insertNewObjectForEntityForName:@"CustomerStore" inManagedObjectContext:[self managedObjectContext]];
    
    GlobalStore *globalStore = [self getGlobalStore];
    offlineSalesStore.invoice_no = invoice_no;
    offlineSalesStore.customer_code = globalStore.customer_default_code;
    offlineSalesStore.payment_type = [self getDataStore:PAYMENT_TYPE];
    
    
    NSArray *cartStores = [self getCartStores];
    NSMutableArray *carts = [NSMutableArray array];
    for (CartStore *cartStore in cartStores) {
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        CustomerStore *customerStore = [self getCustomerStore:globalStore.customer_default_code];
        
        [data setObject:cartStore.cart_code forKey:@"cart_code"];
        [data setObject:cartStore.qty forKey:@"qty"];
        [data setObject:customerStore.code forKey:@"customer_code"];
        [data setObject:customerStore.priceCode forKey:@"pricelist_code"];
        [data setObject:cartStore.cartProduct.itemNo forKey:@"itemNo"];
     
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
        [carts addObject:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];

    }
    offlineSalesStore.carts = [carts componentsJoinedByString:@","];
    [self saveContext];
}

- (NSArray*) getOfflineSalesStore {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fectchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"OfflineSalesStore"
                                                         inManagedObjectContext:context];
    [fectchRequest setEntity: entityDescription];
    
    NSSortDescriptor *sortDescription = [[NSSortDescriptor alloc] initWithKey:@"invoice_no" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray * sortDescriptionArray = [[NSArray alloc] initWithObjects: sortDescription, nil];
    [fectchRequest setSortDescriptors: sortDescriptionArray];
    NSError *error = nil;
    
    NSArray *results = [context executeFetchRequest:fectchRequest error:&error];
    return results;
}

- (void) removeOfflineSalesStore {
    NSArray * offlineSalesStores = [self getOfflineSalesStore];
    for (OfflineSalesStore *offlineSalesStore in offlineSalesStores) {
        [self removeEntityObject:offlineSalesStore];
    }
}

- (void) clearCache {
    NSArray *productStores = [self getProductStores:@""];
    for (ProductStore *productStore in productStores) {
        [self removeEntityObject:productStore];
    }
    
    NSArray *cartStores = [self getCartStores];
    for (CartStore *cartStore in cartStores) {
        [self removeEntityObject:cartStore];
    }
   
    NSArray *customerStores = [self getCustomerStores:@""];
    for (CustomerStore *customerStore in customerStores) {
        [self removeEntityObject:customerStore];
    }
    
    [self removeEntityObject:[self getGlobalStore]];
    [self removeFromKeyChain:USER_PIN_IDENT];
    [self removeFromKeyChain:USER_LOGGED_IDENT];
    [self removeFromKeyChain:SYNC_DATE_LAST_UPDATED];
    [_dataStore removeAllObjects];
 }

- (void) clearCurrentTransaction {
    NSArray *cartStores = [self getCartStores];
    for (CartStore *cartStore in cartStores) {
        [self removeEntityObject:cartStore];
    }
    [_dataStore removeAllObjects];
    GlobalStore *globalStore = [self getGlobalStore];
    globalStore.customer_default_code = globalStore.customer_default_code_copy;
    [self saveContext];
}

#pragma mark - Public methods - sync 
- (void) syncProducts:(APIManager *)apiManager response:(Response *)response completedCallback:(void (^)(void))callbackBlock {
    
    NSMutableArray *operations  = [NSMutableArray array];
    NSDictionary *data_metaData = [((NSDictionary*)response.data) objectForKey:@"metadata"];
    MetaData *raw_metaData = [MTLJSONAdapter modelOfClass:MetaData.class fromJSONDictionary:data_metaData error:nil];
    NSArray *data_content = [MTLJSONAdapter modelsOfClass:Product.class
                                            fromJSONArray:(NSArray*)[(NSDictionary*)response.data objectForKey:@"content"] error:nil];
    
    if (raw_metaData.first) {
        _responseData = [[NSMutableArray alloc] init];
        [persistenceManager setDataStore:SYNC_DATE_LAST_UPDATED value:[raw_metaData.date_last_updated stringValue]];
    }
    [_responseData addObjectsFromArray:data_content];
    
    if (raw_metaData.first) {
        
        if ([raw_metaData.totalElements integerValue] > PAGE_LIMIT) {
            for (int page=1;page<[raw_metaData.totalPages integerValue];page++) {
                AFHTTPRequestOperation *operation = [apiManager getProducts:page];
                [operations addObject:operation];
            }
            
            NSArray *operationQueues = [AFURLConnectionOperation batchOfRequestOperations:operations
                                                                            progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                                                                                DebugLog(@"%lu of %lu complete",(unsigned long)numberOfFinishedOperations,(unsigned long)totalNumberOfOperations);
                                                                                
                                                                            } completionBlock:^(NSArray *operations) {
                                                                                DebugLog(@"All operations in batch complete:%lu", (unsigned long)_responseData.count);
                                                                                for (Product *product in _responseData) {
                                                                                    [persistenceManager setProductStore:product];
                                                                                }
                                                                                if (callbackBlock!=nil) {
                                                                                    callbackBlock();
                                                                                }
                                                                                
                                                                            }];
            
            [[NSOperationQueue mainQueue] addOperations:operationQueues waitUntilFinished:NO];
            
            
        } else {
            for (Product *product in _responseData) {
                [persistenceManager setProductStore:product];
            }
            
            if (callbackBlock!=nil) {
                callbackBlock();
            }
        }
    }
}

- (void) syncCustomers:(APIManager *)apiManager response:(Response *)response completedCallback:(void (^)(void))callbackBlock {
    
    NSMutableArray *operations  = [NSMutableArray array];
    NSDictionary *data_metaData = [((NSDictionary*)response.data) objectForKey:@"metadata"];
    MetaData *raw_metaData = [MTLJSONAdapter modelOfClass:MetaData.class fromJSONDictionary:data_metaData error:nil];
    NSError *error;
    NSArray *data_content = [MTLJSONAdapter modelsOfClass:Customer.class
                                            fromJSONArray:(NSArray*)[(NSDictionary*)response.data objectForKey:@"content"] error:&error];
    
    if (raw_metaData.first) {
        _responseData = [[NSMutableArray alloc] init];
        [persistenceManager setDataStore:SYNC_DATE_LAST_UPDATED value:[raw_metaData.date_last_updated stringValue]];
    }
    [_responseData addObjectsFromArray:data_content];
    
    if (raw_metaData.first) {
        
        if ([raw_metaData.totalElements integerValue] > PAGE_LIMIT) {
            for (int page=1;page<[raw_metaData.totalPages integerValue];page++) {
                AFHTTPRequestOperation *operation = [apiManager getCustomers:page];
                [operations addObject:operation];
            }
            
            NSArray *operationQueues = [AFURLConnectionOperation batchOfRequestOperations:operations
                                                                            progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                                                                                DebugLog(@"%lu of %lu complete",(unsigned long)numberOfFinishedOperations,(unsigned long)totalNumberOfOperations);
                                                                                
                                                                            } completionBlock:^(NSArray *operations) {
                                                                                DebugLog(@"All operations in batch complete:%lu", (unsigned long)_responseData.count);
                                                                                for (Customer *customer in _responseData) {
                                                                                    [persistenceManager setCustomerStore:customer];
                                                                                }
                                                                                if (callbackBlock!=nil) {
                                                                                    callbackBlock();
                                                                                }
                                                                                
                                                                            }];
            
            [[NSOperationQueue mainQueue] addOperations:operationQueues waitUntilFinished:NO];
            
            
        } else {
            for (Customer *customer in _responseData) {
                [persistenceManager setCustomerStore:customer];
            }
            
            if (callbackBlock!=nil) {
                callbackBlock();
            }
        }
    }
}

- (void) syncPriceLists:(APIManager *)apiManager response:(Response *)response completedCallback:(void (^)(void))callbackBlock {
    
    NSMutableArray *operations  = [NSMutableArray array];
    NSDictionary *data_metaData = [((NSDictionary*)response.data) objectForKey:@"metadata"];
    MetaData *raw_metaData = [MTLJSONAdapter modelOfClass:MetaData.class fromJSONDictionary:data_metaData error:nil];
    NSError *error;
    NSArray *data_content = [MTLJSONAdapter modelsOfClass:PriceList.class
                                            fromJSONArray:(NSArray*)[(NSDictionary*)response.data objectForKey:@"content"] error:&error];
    
    if (raw_metaData.first) {
        _responseData = [[NSMutableArray alloc] init];
        [persistenceManager setDataStore:SYNC_DATE_LAST_UPDATED value:[raw_metaData.date_last_updated stringValue]];
    }
    [_responseData addObjectsFromArray:data_content];
    
    if (raw_metaData.first) {
        
        if ([raw_metaData.totalElements integerValue] > PAGE_LIMIT) {
            for (int page=1;page<[raw_metaData.totalPages integerValue];page++) {
                AFHTTPRequestOperation *operation = [apiManager getPriceLists:page];
                [operations addObject:operation];
            }
            
            NSArray *operationQueues = [AFURLConnectionOperation batchOfRequestOperations:operations
                                                                            progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                                                                                DebugLog(@"%lu of %lu complete",(unsigned long)numberOfFinishedOperations,(unsigned long)totalNumberOfOperations);
                                                                                
                                                                            } completionBlock:^(NSArray *operations) {
                                                                                DebugLog(@"All operations in batch complete:%lu", (unsigned long)_responseData.count);
                                                                                for (PriceList *priceList in _responseData) {
                                                                                    [persistenceManager setPriceListStore:priceList];
                                                                                }
                                                                                if (callbackBlock!=nil) {
                                                                                    callbackBlock();
                                                                                }
                                                                                
                                                                            }];
            
            [[NSOperationQueue mainQueue] addOperations:operationQueues waitUntilFinished:NO];
            
            
        } else {
            for (PriceList *priceList in _responseData) {
                [persistenceManager setPriceListStore:priceList];
            }
            
            if (callbackBlock!=nil) {
                callbackBlock();
            }
        }
    }
}

- (void) syncPrices:(APIManager *)apiManager response:(Response *)response completedCallback:(void (^)(void))callbackBlock {
    
    NSMutableArray *operations  = [NSMutableArray array];
    NSDictionary *data_metaData = [((NSDictionary*)response.data) objectForKey:@"metadata"];
    MetaData *raw_metaData = [MTLJSONAdapter modelOfClass:MetaData.class fromJSONDictionary:data_metaData error:nil];
    NSError *error;
    NSArray *data_content = [MTLJSONAdapter modelsOfClass:Price.class
                                            fromJSONArray:(NSArray*)[(NSDictionary*)response.data objectForKey:@"content"] error:&error];
    
    if (raw_metaData.first) {
        _responseData = [[NSMutableArray alloc] init];
        [persistenceManager setDataStore:SYNC_DATE_LAST_UPDATED value:[raw_metaData.date_last_updated stringValue]];
    }
    [_responseData addObjectsFromArray:data_content];
    
    if (raw_metaData.first) {
        
        if ([raw_metaData.totalElements integerValue] > PAGE_LIMIT) {
            for (int page=1;page<[raw_metaData.totalPages integerValue];page++) {
                AFHTTPRequestOperation *operation = [apiManager getPrices:page];
                [operations addObject:operation];
            }
            
            NSArray *operationQueues = [AFURLConnectionOperation batchOfRequestOperations:operations
                                                                            progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                                                                                DebugLog(@"%lu of %lu complete",(unsigned long)numberOfFinishedOperations,(unsigned long)totalNumberOfOperations);
                                                                                
                                                                            } completionBlock:^(NSArray *operations) {
                                                                                DebugLog(@"All operations in batch complete:%lu", (unsigned long)_responseData.count);
                                                                                for (Price *price in _responseData) {
                                                                                    [persistenceManager setPriceStore:price];
                                                                                }
                                                                                if (callbackBlock!=nil) {
                                                                                    callbackBlock();
                                                                                }
                                                                                
                                                                            }];
            
            [[NSOperationQueue mainQueue] addOperations:operationQueues waitUntilFinished:NO];
            
            
        } else {
            for (Price *price in _responseData) {
                [persistenceManager setPriceStore:price];
            }
            
            if (callbackBlock!=nil) {
                callbackBlock();
            }
        }
    }
}


#pragma mark - Private methods
-(NSString*)newUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    
    NSString *result = [((__bridge NSString *)string) stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    CFRelease(theUUID);
    CFRelease(string);
    
    return result;
}



// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        //[_managedObjectContext setUndoManager:nil];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"POS.db"];
    
    // handle db upgrade
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]){
        /*
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    return _persistentStoreCoordinator;
}


@end
