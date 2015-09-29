
#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "Mantle.h"

@interface Customer : MTLModel <MTLJSONSerializing>

/*!
 * Customer identifier , the customer identifier
 */
@property (nonatomic, strong)  NSNumber *identifier;
/*!
 * Customer address1 , the address 1
 */
@property (nonatomic, strong)  NSString *address1;
/*!
 * Customer address2 , the address 2
 */
@property (nonatomic, strong)  NSString *address2;
/*!
 * Customer address3 , the address 3
 */
@property (nonatomic, strong)  NSString *address3;
/*!
 * Customer address4 , the address 4
 */
@property (nonatomic, strong)  NSString *address4;
/*!
 * Customer code , the customer code
 */
@property (nonatomic, strong)  NSString *code;
/*!
 * Customer currency , the customer currency
 */
@property (nonatomic, strong)  NSString *currency;
/*!
* Customer group , the customer group
*/
@property (nonatomic, strong)  NSString *group;
/*!
 * Customer name , the customer name
 */
@property (nonatomic, strong)  NSString *name;
/*!
* Customer priceCode , the customer priceCode
*/
@property (nonatomic, strong)  NSString *priceCode;
/*!
 * Customer status , the customer status
 */
@property (nonatomic, strong)  NSString *status;
/*!
 * Customer taxGroup , the customer taxGroup
 */
@property (nonatomic, strong)  NSString *taxGroup;
/*!
 * Customer email , the customer email
 */
@property (nonatomic, strong)  NSString *email;
@end