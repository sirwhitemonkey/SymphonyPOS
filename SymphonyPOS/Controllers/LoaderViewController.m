
#import "LoaderViewController.h"

@interface LoaderViewController ()

@end

@implementation LoaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Public methods
- (void) start {
     [self.indicatorView startAnimating];
}

- (void) stop {
    [self.indicatorView stopAnimating];
    [self.delegate loaderDidCompleted:self];
}
@end
