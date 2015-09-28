
#import "PriceList.h"

@implementation PriceList

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"identifier" : @"id",
             @"code" : @"code",
             @"desc" : @"desc"
          
             };
}

@end
