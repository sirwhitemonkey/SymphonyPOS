
// Response json object serialisable using Mantle framework
// Check the sample json responses from 'Mock' folder of the app.
#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "Mantle.h"

@interface Response :  MTLModel <MTLJSONSerializing>

/*!
 * Response error, error flag
 */
@property (nonatomic,assign) BOOL error;

/*!
 * Response message , messages from server
 */
@property (nonatomic, strong)  NSString *message;

/*!
 * Response token , unique token identifier generated from server during successful login
 */
@property (nonatomic, strong)  NSString *token;

/*!
 * Response date_last_updated , date last updates during the sync process
 */
@property (nonatomic, strong)  NSString *date_last_updated;

/*!
 * Response data , the raw data  i.e products,pricelists,customers,global items
 */
@property (nonatomic) NSDictionary *data;

@end