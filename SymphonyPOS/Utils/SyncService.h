
#import <Foundation/Foundation.h>


@protocol SyncServiceDelegate <NSObject>
/*!
 * SyncServiceDelegate start timer action callback.
 */
- (void)startTimerAction:(id)userInfo;
@end

@interface SyncService : NSObject{
    
    NSTimer *repeatingTimer;
    /*!
     * SyncService delegate, the SyncServiceDelegate instance
     */
    id <SyncServiceDelegate> delegate;
}
/*!
 * SyncService shared instance
 */
+ (SyncService *)sharedInstance;

/*!
 * SyncService start timer for sender request
 */
- (void)startTimerForSender:(id <SyncServiceDelegate>)sender withTimeInterval:(NSTimeInterval)time;
/*!
 * SyncService stopping the timer request
 */
- (void)stopTimer;

@end