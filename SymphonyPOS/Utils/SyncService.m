
#import "SyncService.h"

@implementation SyncService

+ (SyncService *)sharedInstance {
    static SyncService *singletonInstance;
    
    if (singletonInstance == nil) {
        singletonInstance =  [[super allocWithZone:NULL] init];
    }
    return singletonInstance;
}

+ (id)allocWithZone:(NSZone *)zone{
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone{
    return self;
}

#pragma mark - Public
- (void)startTimerForSender:(id <SyncServiceDelegate>)sender withTimeInterval:(NSTimeInterval)time{
    if (repeatingTimer) {
        [self stopTimer];
    }
    
    if (sender) {
        delegate = sender;
    }
    
    if (time > 0.0) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(targetMethod:)
                                                        userInfo:[self userInfo] repeats:YES];
        repeatingTimer = timer;
    }
}

- (void)stopTimer{
    if (repeatingTimer) {
        [repeatingTimer invalidate];
        repeatingTimer = nil;
    }
}

- (NSDictionary *)userInfo{
    return @{@"StartDate" : [NSDate date]};
}

- (void)targetMethod:(NSTimer*)theTimer{
    if (delegate && [delegate respondsToSelector:@selector(startTimerAction:)]) {
        [delegate startTimerAction:[repeatingTimer userInfo]];
    }
}



@end