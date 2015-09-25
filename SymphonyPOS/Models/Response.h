
// Response json object serialisable using Mantle framework

#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "Mantle.h"

@interface Response :  MTLModel <MTLJSONSerializing>

/*!
 * Response code
 */
@property (nonatomic,strong) NSNumber *responseCode;

/*!
 * Response data
 */
@property (nonatomic,strong) NSObject *data;

@end