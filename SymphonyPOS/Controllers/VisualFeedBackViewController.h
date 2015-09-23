

#import <UIKit/UIKit.h>

@interface VisualFeedBackViewController : UIViewController
@property(nonatomic,strong) IBOutlet UIActivityIndicatorView *indicatorView;
@property(nonatomic,strong) IBOutlet UILabel *label;

- (void) initialise:(BOOL) loader message:(NSString*)message error:(BOOL)error;
@end
