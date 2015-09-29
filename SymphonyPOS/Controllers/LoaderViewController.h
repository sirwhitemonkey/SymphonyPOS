

#import <UIKit/UIKit.h>

@protocol LoaderViewControllerDelegate;

@interface LoaderViewController : UIViewController
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic,weak) id<LoaderViewControllerDelegate>delegate;

- (void) start;
- (void) stop;

@end

@protocol LoaderViewControllerDelegate
- (void) loaderDidCompleted: (LoaderViewController*)controller;

@end
