
#import "Response.h"

@implementation Response


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"responseCode" : @"responseCode",
             @"data" : @"data"
             };
}

@end
