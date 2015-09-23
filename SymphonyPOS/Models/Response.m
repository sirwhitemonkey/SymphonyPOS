
#import "Response.h"

@implementation Response


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"error" : @"error",
             @"message" : @"message",
             @"token" : @"token",
             @"date_last_updated" : @"date_last_updated",
             @"data" : @"data"
             };
}

+ (NSValueTransformer *)errorJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}
@end
