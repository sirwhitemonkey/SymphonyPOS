#import "Customer.h"

@implementation Customer

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"identifier" : @"id",
             @"address1" : @"address1",
             @"address2" : @"address2",
             @"address3" : @"address3",
             @"address4" : @"address4",
             @"code" : @"code",
             @"currency" : @"currency",
             @"email" : @"email",
             @"group" : @"group",
              @"name" : @"name",
             @"priceCode" : @"priceCode",
             @"status" : @"status",
             @"taxGroup" : @"taxGroup"
             };
}

@end
