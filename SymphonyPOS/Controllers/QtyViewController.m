
#import "QtyViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface QtyViewController ()
@property (nonatomic,strong) ProductStore *currentProductStore;
@property (nonatomic,strong) GlobalStore *globalStore;
@property (nonatomic,strong) NSDictionary *themes;
@end

@implementation QtyViewController
@synthesize delegate;
@synthesize currentProductStore = _currentProductStore;
@synthesize globalStore = _globalStore;
@synthesize themes = _themes;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     self.qtyView.layer.borderWidth = 1;
    self.qtyView.layer.borderColor =[[UIColor  grayColor] CGColor];
    
    _globalStore = [persistenceManager getGlobalStore];
    NSData *data = [_globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
    _themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
   
    [self.qtyView setBackgroundColor:[service colorFromHexString:
                                                    [_themes objectForKey:@"background"]]];
    [self.nextBtn setBackgroundColor:[service colorFromHexString:
                                      [_themes objectForKey:@"button_submit"]]];
   
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

- (void)initialise:(ProductStore *)productStore {
    _currentProductStore = productStore;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self registerNotifications];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - Notifications

- (void)registerNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - UITextField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ( [finalString length] <= 3 ) {
        
        return YES;
    }
    return NO;
}


#pragma mark - IBActions
- (IBAction)next:(id)sender {
    if ([service isEmptyString:self.qty.text]) {
        self.qty.text = @"1";
    }
   
    [self.delegate qtyDidCompleted:self qty:[NSNumber numberWithLong:[self.qty.text integerValue]]
                      productStore:_currentProductStore];
    
}

#pragma mark - Private methods
- (void) willEnterForegroundNotification {
    [service showPinView:self];
}


@end
