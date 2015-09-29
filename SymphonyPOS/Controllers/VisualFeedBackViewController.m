

#import "VisualFeedBackViewController.h"

@interface VisualFeedBackViewController ()
@property (nonatomic,strong) NSString *message;
@property BOOL error;
@property BOOL loader;

@end

@implementation VisualFeedBackViewController
@synthesize message = _message;
@synthesize error = _error;
@synthesize loader = _loader;

- (void)viewDidLoad {
    [super viewDidLoad];
    DebugLog(@"viewDidLoad");
    
    [self.indicatorView setHidden:YES];
    
    if (_loader) {
       [self.indicatorView startAnimating];
        [self.indicatorView setHidden:NO];
    }
    
    if (_error) {
        self.label.textColor = WARNING;
    }
    self.label.text =  _message;
    
    [self.view setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate{
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}
#endif

#pragma mark - Public methods
- (void) initialise:(BOOL) loader message:(NSString*)message error:(BOOL)error {
    _loader = loader;
    _message = message;
    _error = error;
}

@end
