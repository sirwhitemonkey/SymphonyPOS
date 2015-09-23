
#import "PersistenceManager.h"

@interface PersistenceManager()
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,strong) NSMutableDictionary *dataStore;

- (NSURL *)applicationDocumentsDirectory;

@end

@implementation PersistenceManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize dataStore = _dataStore;
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
#pragma mark - Public methods

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
    PriceListStore *pricelistStore = [self getPriceListByProductStore:pricelist.pricelist_code product_code:pricelist.product_code];
    if (!pricelistStore) {
        pricelistStore = [NSEntityDescription insertNewObjectForEntityForName:@"PriceListStore" inManagedObjectContext:[self managedObjectContext]];
    }
    pricelistStore.pricelist_code = pricelist.pricelist_code;
    pricelistStore.price = pricelist.price;
    pricelistStore.product_code = pricelist.product_code;
    pricelistStore.currency = pricelist.currency;
    [self saveContext];
    
}

- (PriceListStore*) getPriceListStore:(NSString*)pricelist_code {
    NSManagedObjectContext *context = [self managedObjectContext];
    pricelist_code=[[pricelist_code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PriceListStore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pricelist_code =[cd] \"%@\"",pricelist_code]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count>0) {
        return [results objectAtIndex:0];
    }
    return nil;
}

- (PriceListStore*)getPriceListByProductStore:(NSString*)pricelist_code product_code:(NSString*)product_code {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    pricelist_code=[[pricelist_code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PriceListStore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pricelist_code =[cd] \"%@\" && product_code =[cd] \"%@\"",pricelist_code,product_code]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count>0) {
        return [results objectAtIndex:0];
    }
    return nil;

    
}

- (NSArray*)getPriceListStores {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PriceListStore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
     NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    return results;
    
}


- (void) setCustomerStore:(Customer*)customer {
    CustomerStore *customerStore = [self getCustomerStore:customer.customer_code];
    if (!customerStore) {
        customerStore = [NSEntityDescription insertNewObjectForEntityForName:@"CustomerStore" inManagedObjectContext:[self managedObjectContext]];
    }
    customerStore.customer_code = customer.customer_code;
    customerStore.customer_default = [NSNumber numberWithBool:customer.customer_default];
    customerStore.terms = [NSNumber numberWithBool:customer.terms];
    customerStore.pricelist_code = customer.pricelist_code;
    customerStore.customer_description = customer.customer_description;
    [self saveContext];

}

- (CustomerStore*) getCustomerStore:(NSString*)customer_code {
    NSManagedObjectContext *context = [self managedObjectContext];
    customer_code=[[customer_code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CustomerStore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"customer_code =[cd] \"%@\"",customer_code]];
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
    
    NSSortDescriptor *sortDescription = [[NSSortDescriptor alloc] initWithKey:@"customer_description" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray * sortDescriptionArray = [[NSArray alloc] initWithObjects: sortDescription, nil];
    [fectchRequest setSortDescriptors: sortDescriptionArray];
    NSError *error = nil;
    
    NSArray *results = [context executeFetchRequest:fectchRequest error:&error];
    
    if ([sharedServices isEmptyString:searchString]) {
        return results;
    }
    
    if (results.count > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.customer_description CONTAINS %@ ", searchString];
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
       globalStore= [NSEntityDescription insertNewObjectForEntityForName:@"GlobalStore" inManagedObjectContext:[self managedObjectContext]];
    }
    return globalStore;
 
}

- (void)setProductStore:(Product*)product {

    ProductStore *productStore = [self getProductStore:product.product_code];
    if (!productStore) {
        productStore = [NSEntityDescription insertNewObjectForEntityForName:@"ProductStore" inManagedObjectContext:[self managedObjectContext]];
    }
    productStore.product_code = product.product_code;
    productStore.product_name = product.product_name;
    productStore.product_description = product.product_description;
    productStore.image_url = product.image_url;
    productStore.unit = product.unit;
    productStore.product_description = product.product_description;
    productStore.pc_code = product.pc_code;
    [self saveContext];

}

- (ProductStore*)getProductStore:(NSString*)product_id {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    product_id=[[product_id stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProductStore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"product_code =[cd] \"%@\"",product_id]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (results.count>0)
        return [results objectAtIndex:0];
    
    return nil;
}

- (ProductStore*)getProductStoreByBarcode:(NSString *)barcode {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    barcode=[[barcode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProductStore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pc_code =[cd] \"%@\"",barcode]];
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
    
    NSSortDescriptor *sortDescription = [[NSSortDescriptor alloc] initWithKey:@"product_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray * sortDescriptionArray = [[NSArray alloc] initWithObjects: sortDescription, nil];
    [fectchRequest setSortDescriptors: sortDescriptionArray];
    NSError *error = nil;
    
    NSArray *results = [context executeFetchRequest:fectchRequest error:&error];
    
    if ([sharedServices isEmptyString:searchString]) {
        return results;
    }
    
    if (results.count > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.product_name CONTAINS %@", searchString];
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
    
    cart_code=[[cart_code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
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

- (CartStore*)getCartByProductStore:(NSString*)product_code {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    product_code=[[product_code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CartStore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"cartProduct.product_code =[cd] \"%@\"",product_code]];
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
    
    NSSortDescriptor *sortDescription = [[NSSortDescriptor alloc] initWithKey:@"cartProduct.product_name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray * sortDescriptionArray = [[NSArray alloc] initWithObjects: sortDescription, nil];
    [fectchRequest setSortDescriptors: sortDescriptionArray];
    NSError *error = nil;
    
    NSArray *results = [context executeFetchRequest:fectchRequest error:&error];
    return results;
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
        
        PriceListStore *priceListStore = [self getPriceListByProductStore:customerStore.pricelist_code
                                                             product_code:cartStore.cartProduct.product_code];
        [data setObject:cartStore.cart_code forKey:@"cart_code"];
        [data setObject:cartStore.qty forKey:@"qty"];
        [data setObject:customerStore.customer_code forKey:@"customer_code"];
        [data setObject:priceListStore.pricelist_code forKey:@"pricelist_code"];
        [data setObject:cartStore.cartProduct.product_code forKey:@"product_code"];
     
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

- (void) clearAllEvents {
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
    [self removeFromKeyChain:APP_USER_IDENT];
    [self removeFromKeyChain:APP_USER_PIN_IDENT];
    [self removeFromKeyChain:API_SYNC_DATE_LAST_UPDATED];
    [self removeFromKeyChain:PASSKEY];
    [_dataStore removeAllObjects];
 }

- (void) clearCurrentEvent {
    NSArray *cartStores = [self getCartStores];
    for (CartStore *cartStore in cartStores) {
        [self removeEntityObject:cartStore];
    }
    [_dataStore removeAllObjects];
    GlobalStore *globalStore = [self getGlobalStore];
    globalStore.customer_default_code = globalStore.customer_default_code_copy;
    [self saveContext];
    [self clearPaymentEvent];
}

- (void) clearPaymentEvent {
    [self removeFromKeyChain:PAYMENT_CREDITCARD];
}

- (void)updateSync:(id)reference response:(Response *)response {
    DebugLog(@"updateSync -> %@", response);
    
    if (response.error) {
        [sharedServices showMessage:reference message:@"Synchronisation communication failed from server." error:YES withCallBack:nil];
        return;
    }
    
    NSArray *raw_products = [MTLJSONAdapter modelsOfClass:Product.class fromJSONArray:(NSArray*)[response.data objectForKey:@"products"] error:nil];
    for (Product *product in raw_products) {
        [self setProductStore:product];
    }
    
    NSArray *raw_pricelists = [MTLJSONAdapter modelsOfClass:PriceList.class fromJSONArray:(NSArray*)[response.data objectForKey:@"pricelists"] error:nil];
    for (PriceList *pricelist in raw_pricelists) {
        [self setPriceListStore:pricelist];
    }
    
    NSArray *raw_customers = [MTLJSONAdapter modelsOfClass:Customer.class fromJSONArray:(NSArray*)[response.data objectForKey:@"customers"] error:nil];
    for (Customer *customer in raw_customers) {
        [self setCustomerStore:customer];
    }
    
    GlobalItems *raw_globalItems = [MTLJSONAdapter modelOfClass:GlobalItems.class fromJSONDictionary:response.data error:nil];
    GlobalStore *globalStore = [self getGlobalStore];
    globalStore.sales_percentage_tax = raw_globalItems.sales_percentage_tax;
    globalStore.last_order_number = raw_globalItems.last_order_number;
    globalStore.prefix = raw_globalItems.prefix;
    globalStore.prefix_number_length = raw_globalItems.prefix_number_length;
    globalStore.customer_default_code =  raw_globalItems.customer_default_code;
    globalStore.customer_default_code_copy =raw_globalItems.customer_default_code;
    if ([globalStore.days_sync_interval integerValue] == 0) {
        globalStore.days_sync_interval = [NSNumber numberWithInt:30];
    }
     [self saveContext];
    
    [self updateSettingsBundle];
    
    [self setKeyChain:API_SYNC_DATE_LAST_UPDATED value:response.date_last_updated];
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
                if ([sharedServices isEmptyString:value]) {
                    if (globalStore.terminal_name != nil) {
                        value = globalStore.terminal_name;
                    }
                }
                globalStore.terminal_name = value;
            }
            else  if ([key isEqualToString:@"terminal_code"]) {
                if ([sharedServices isEmptyString:value]) {
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
    [persistenceManager saveContext];
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
