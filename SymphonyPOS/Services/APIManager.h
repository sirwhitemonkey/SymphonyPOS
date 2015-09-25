
// Handles the API rest services communication using AFNetworking framework

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "VisualFeedbackViewController.h"
#import "Response.h"
#import "GlobalStore.h"
#import "CocoaWSSE.h"
#import "JSONResponseSerializerWithData.h"


@protocol APIManagerDelegate <NSObject>

@required
/*!
 * APIManagerDelegate request error callback
 */
- (void) apiRequestError:(NSError*)error;

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
 * APIManagerDelegate sync callback.
 */
- (void) apiSyncResponse:(Response*)response;

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

/*!
 * APIManagerDelegate submit authorisation callback
 * Submission of authorisation data for data encryption
 */
- (void) apiSubmitAuthorisationResponse:(Response*)response;

/*!
 * APIManagerDelegate get products callback
 */
- (void) apiProductsResponse:(Response*)response;


@end

@interface APIManager : NSObject
/*!
 * APIManager delegate, the  APIManagerDelegate instance
 */
@property (weak) id<APIManagerDelegate> delegate;

/*!
 * APIManager auth submit request
 */
- (AFHTTPRequestOperation*) authSubmit:(id)reference;

/*!
 * APIManager themes request
 */
- (AFHTTPRequestOperation*) themes:(id)reference group:(BOOL)group;

/*!
 * APIManager data defaults request
 */
- (AFHTTPRequestOperation*) dataDefaults:(id)reference group:(BOOL)group;



























/*!
 * APIManager sync data  request
 */
- (void) sync:(id)reference;

/*!
 * APIManager checking of connection request
 */
- (void) checkConnection:(id)reference;

/*!
 * APIManager payment submission request
 */
- (void) submitPayment:(id) reference invoice_no:(NSString*)invoice_no;

/*!
 * APIManager synchronisation of offline sales request.
 */
- (void) offlineSales:(id) reference;

/*!
 * APIManager submission of authorisation data for encryption request.
 */
- (void) submitAuthorisation:(id)reference;



/*!
 * APIManager synchronisation of image on the background request.
 */
- (void) syncImage:(UIImageView*) refImageView url:(NSString*)url;





/*!
 * APIManager get the products
 */
- (void) getProducts:(id)reference page:(int)page limit:(int)limit;

@end

