
// Handles the API rest services communication using AFNetworking framework

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "Response.h"
#import "GlobalStore.h"
#import "CocoaWSSE.h"
#import "JSONResponseSerializerWithData.h"


@protocol APIManagerDelegate <NSObject>

@required
/*!
 * APIManagerDelegate request error callback
 */
- (void) apiRequestError:(NSError*)error response:(Response*)response;

@optional
/*!
 * APIManagerDelegate auth submit callback.
 */
- (void) apiAuthSubmitResponse:(Response*)response;

/*!
 * APIManagerDelegate themes callback.
 */
- (void) apiThemesResponse:(Response*)response;

/*!
 * APIManagerDelegate data defaults callback.
 */
- (void) apiDataDefaultsResponse:(Response*)response;

/*!
 * APIManagerDelegate get products callback
 */
- (void) apiProductsResponse:(Response*)response;

/*!
 * APIManagerDelegate get customers callback
 */
- (void) apiCustomersResponse:(Response*)response;

/*!
 * APIManagerDelegate get pricelists callback
 */
- (void) apiPriceListsResponse:(Response*)response;
/*!
 * APIManagerDelegate get prices callback
 */
- (void) apiPricesResponse:(Response*)response;

/*!
 * APIManagerDelegate check connection  callback.
 */
- (void) apiCheckConnnectionResponse:(Response*) response;

/*!
 * APIManagerDelegate submit payment callback
 * Payment submission received.
 */
- (void) apiSubmitPaymentResponse:(Response*) response;

/*!
 * APIManagerDelegate offline sales callback.
 * Offline sales synchronisation.
 */
- (void) apiOfflineSalesResponse:(Response*) response;


@end

@interface APIManager : NSObject
/*!
 * APIManager delegate, the  APIManagerDelegate instance
 */
@property (weak) id<APIManagerDelegate> delegate;

@property BOOL batchOperation;

/*!
 * APIManager auth submit request
 */
- (AFHTTPRequestOperation*) authSubmit;

/*!
 * APIManager themes request
 */
- (AFHTTPRequestOperation*) themes;

/*!
 * APIManager data defaults request
 */
- (AFHTTPRequestOperation*) dataDefaults;

/*!
 * APIManager get the products
 */
- (AFHTTPRequestOperation*) getProducts:(int)page;

/*!
 * APIManager get the customers
 */
- (AFHTTPRequestOperation*) getCustomers:(int)page;

/*!
 * APIManager get the pricelists
 */
- (AFHTTPRequestOperation*) getPriceLists:(int)page;

/*!
 * APIManager get the prices
 */
- (AFHTTPRequestOperation*) getPrices:(int)page;

/*!
 * APIManager checking of connection request
 */
- (AFHTTPRequestOperation*) checkConnection;

/*!
 * APIManager payment submission request
 */
- (void) submitPayment:(id) reference invoice_no:(NSString*)invoice_no;

/*!
 * APIManager synchronisation of offline sales request.
 */
- (AFHTTPRequestOperation*) offlineSales;

/*!
 * APIManager synchronisation of image on the background request.
 */
- (void) syncImage:(UIImageView*) refImageView url:(NSString*)url;







@end

