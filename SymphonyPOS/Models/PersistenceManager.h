#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>
#import "KeychainWrapper.h"
#import "ProductStore+CoreDataProperties.h"
#import "CartStore.h"
#import "PriceListStore.h"
#import "CustomerStore.h"
#import "GlobalStore.h"
#import "Product.h"
#import "PriceList.h"
#import "Customer.h"
#import "DataDefaults.h"
#import "Response.h"
#import "OfflineSalesStore.h"
#import "MetaData.h"
#import "APIManager.h"
#import "Constants.h"

@interface PersistenceManager : NSObject
/*!
 * PersistenceManager offline, the flag for offline during payment
 */
@property (nonatomic,assign) BOOL offline;

/*!
 * PersistenceManager shared instance
 */
+ (PersistenceManager*) sharedInstance;

/*!
 * PersistenceManager initialising the data
 */
- (id) initWithData;

/*!
 * PersistenceManager coredata object context management
 */
- (NSManagedObjectContext *)managedObjectContext;

/*!
 * PersistenceManager coredata object context save event
 */
- (void)saveContext;

/*!
 * PersistenceManager setting/storing the product into coredata
 */
- (void)setProductStore:(Product*)product;

/*!
 * PersistenceManager getting the product from coredata  using product code
 */
- (ProductStore*)getProductStore:(NSString*)itemNo;

/*!
 * PersistenceManager getting the product from coredata using barcode code
 */
- (ProductStore*)getProductStoreByUpcCode:(NSString *)upcCode;

/*!
 * PersistenceManager getting the arrays of products from coredata
 */
- (NSArray*)getProductStores: (NSString*) searchString;

/*!
 * PersistenceManager setting/storing the cart into coredata
 */
- (void)setCartStore:(NSNumber*)qty productStore:(ProductStore*)productStore;

/*!
 * PersistenceManager removing the cart from coredata
 */
- (void)removeCartStore:(NSString*)cart_code;

/*!
 * PersistenceManager getting the cart from coredata using cart code
 */
- (CartStore*)getCartStore:(NSString*)cart_code;

/*!
 * PersistenceManager getting the cart from coredata using product_code
 */
- (CartStore*)getCartByProductStore:(NSString*)product_code;

/*!
 * PersistenceManager updating the cart from coredata
 */
- (void)updateCartStore: (NSString*)cart_code qty:(NSNumber*)qty;

/*!
 * PersistenceManager getting the arrays of carts from coredata
 */
- (NSArray*)getCartStores;

/*!
 * PersistenceManager setting/storing the pricelist into coredata
 */
- (void)setPriceListStore:(PriceList*)pricelist_code;

/*!
 * PersistenceManager getting the pricelist from coredata using pricelist code
 */
- (PriceListStore*)getPriceListStore:(NSString*)pricelist_code;

/*!
 * PersistenceManager getting the arrays of pricelists from coredata
 */
- (NSArray*)getPriceListStores;

/*!
 * PersistenceManager getting the pricelist by product
 */
- (PriceListStore*)getPriceListByProductStore:(NSString*)pricelist_code product_code:(NSString*)product_code;

/*!
 * PersistenceManager setting/storing the customer into coredata
 */
- (void) setCustomerStore:(Customer*)customer;

/*!
 * PersistenceManager getting the customer from coredata
 */
- (CustomerStore*) getCustomerStore:(NSString*)customer_code;

/*!
 * PersistenceManager getting the arrays of customers from coredata
 */
- (NSArray*) getCustomerStores:(NSString*)searchString;

/*!
 * PersistenceManager setting/storing the offline sales into coredata
 */
- (void) setOfflineSalesStore:(NSString*)invoice_no;

/*!
 * PersistenceManager getting the arrays of offline sales from coredata
 */
- (NSArray*) getOfflineSalesStore;

/*!
 * PersistenceManager removing the offline sales
 */
- (void) removeOfflineSalesStore;

/*!
 * PersistenceManager getting the global data from coredata
 */
- (GlobalStore*) getGlobalStore;

/*!
 * PersistenceManager clearing all the events (i.e transactions and data cache)
 */
- (void)clearCache;

/*!
 * PersistenceManager clearing the current transaction
 */
- (void)clearCurrentTransaction;

/*!
 * PersistenceManager setting/storing data into secured keychain
 */
- (void) setKeyChain:(NSString*)key value:(NSString*)value;

/*!
 * PersistenceManager getting data from secured keychain
 */
- (NSString*) getKeyChain:(NSString*)key;

/*!
 * PersistenceManager remove data from secured keychain
 */
- (void)removeFromKeyChain:(NSString*)key;

/*!
 * PersistenceManager setting/storing data into memory
 */
- (void) setDataStore: (NSString*) key value:(id)value;

/*!
 * PersistenceManager getting data from memory
 */
- (id) getDataStore: (NSString*)key;

/*!
 * PersistenceManager removing data from memory
 */
- (void) removeDataStore: (NSString*)key;

/*!
 * PersistenceManager getting the view controller from storyboard
 */
- (UIViewController*) getView:(NSString*)identifier;

/*!
 * PersistenceManager updating the data during sync process
 */
- (void) updateSync:(id)reference response:(Response*) response;

/*!
 * PersistenceManager updating the settings in the bundle
 */
- (void) updateSettingsBundle;

/*!
 * PersistenceManager setting the my custom preferences
 */
- (void) setMyCustomPreference:(NSString*)url logo:(NSString*)logo;

/*!
 * PersistenceManager sync products
 */
- (void) syncProducts: (APIManager*)apiManager response:(Response*)response completedCallback:(void (^)(void))callbackBlock;

@end
