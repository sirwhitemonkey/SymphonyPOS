
#import "SignatureViewController.h"

@interface SignatureViewController ()
@property (nonatomic,strong) GlobalStore *globalStore;
@property (nonatomic,strong) NSDictionary *themes;
@property (nonatomic,strong) UIImageView *drawImage;
@property CGPoint lastPoint;
@property BOOL mouseSwiped;
@property int mouseMoved;

@end

@implementation SignatureViewController
@synthesize globalStore = _globalStore;
@synthesize themes = _themes;
@synthesize drawImage = _drawImage;
@synthesize lastPoint = _lastPoint;
@synthesize mouseSwiped = _mouseSwiped;
@synthesize mouseMoved = _mouseMoved;
@synthesize  delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    _globalStore = [persistenceManager getGlobalStore];
    
    NSData *data = [_globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
    _themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    [self.view setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"background"]]];
    [self.clearSignatureBtn setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"button_remove"]]];
    [self.completeSignatureBtn setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"button_submit"]]];
    
    _drawImage = [[UIImageView alloc] initWithImage:nil];
    _drawImage.frame = self.signatureView.frame;
    [self.view addSubview:_drawImage];

    self.signatureView.layer.borderWidth = 1;
    self.signatureView.layer.borderColor = [[UIColor  grayColor] CGColor];
    if ([persistenceManager getDataStore:PAYMENT_CREDITCARDSIGNATURE] != nil) {
        _drawImage.image = [persistenceManager getDataStore:PAYMENT_CREDITCARDSIGNATURE];
    }
    
    
    
 }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - IBActions
- (IBAction)clearSignature:(id)sender {
    DebugLog(@"clearSignature");
    _mouseMoved = 0;
    _drawImage.image = nil;
}

- (IBAction)completeSignature:(id)sender {
    [self.delegate didSignatureFinished:self image:_drawImage.image];
}

#pragma mark - UIView
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    _mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    
    if ([touch tapCount] == 2) {
        _drawImage.image = nil;
        return;
    }
    
    _lastPoint = [touch locationInView:self.signatureView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    _mouseSwiped = YES;
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.signatureView];
    
    NSLog(@"Line: %dx%d to %dx%d",(int)_lastPoint.x,(int)_lastPoint.y,(int)currentPoint.x,(int)currentPoint.y);
    
    UIGraphicsBeginImageContext(self.signatureView.frame.size);
    [_drawImage.image drawInRect:CGRectMake(0, 0, self.signatureView.frame.size.width, self.signatureView.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 1.0, 1.0);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), _lastPoint.x, _lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    _drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _lastPoint = currentPoint;
    
    _mouseMoved++;
    
    if (_mouseMoved == 10) {
        _mouseMoved = 0;
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    if ([touch tapCount] == 2) {
        _drawImage.image = nil;
        return;
    }
    
    
    if(!_mouseSwiped) {
        UIGraphicsBeginImageContext(self.signatureView.frame.size);
        [_drawImage.image drawInRect:CGRectMake(0, 0, self.signatureView.frame.size.width, self.signatureView.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 0.0, 0.0, 1.0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), _lastPoint.x, _lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), _lastPoint.x, _lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        _drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
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


#pragma mark - Private methods
- (void) willEnterForegroundNotification {
    [service showPinView:self];
}

@end
