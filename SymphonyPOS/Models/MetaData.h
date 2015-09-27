
// Response json object serialisable using Mantle framework

#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "Mantle.h"

@interface MetaData :  MTLModel <MTLJSONSerializing>

/*!
 * MetaData number
 */
@property (nonatomic,strong) NSNumber *number;

/*!
 * MetaData number of elements
 */
@property (nonatomic,strong) NSNumber *numberOfElements;

/*!
 * MetaData total number of pages
 */
@property (nonatomic,strong) NSNumber *totalPages;

/*!
* MetaData size
*/
@property (nonatomic,strong) NSNumber *size;

/*!
 * MetaData total number of elements
 */
@property (nonatomic,strong) NSNumber *totalElements;

/*!
 * MetaData last flag
 */
@property BOOL last;

/*!
 * MetaData last flag
 */
@property BOOL first;
@end