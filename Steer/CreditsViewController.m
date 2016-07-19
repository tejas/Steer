//
//  CreditsViewController.m
//  Steer
//
//  Created by Enterpi iOS on 13/07/16.
//  Copyright © 2016 Enterpi iOS. All rights reserved.
//

#import "CreditsViewController.h"
#import "Steer-Swift.h"
#import <SafariServices/SafariServices.h>

@interface CreditsViewController ()
@property (weak, nonatomic) IBOutlet SparkButton *likeButton;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation CreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.



}

- (void)viewWillAppear:(BOOL)animated
{
    [self showLikeAnimation];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }

    self.timer =   [NSTimer scheduledTimerWithTimeInterval:1.5
                                                    target:self
                                                  selector:@selector(showLikeAnimation)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)showLikeAnimation
{
    [_likeButton setImage:[UIImage imageNamed:@"liked"] forState:UIControlStateNormal];
    [_likeButton likeBounce:0.6];
    [_likeButton animate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillDisappear:(BOOL)animated {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (IBAction)goToEnterpiWebsite:(id)sender {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://enterpi.com/"]];
    if ([[UIDevice currentDevice].systemVersion hasPrefix:@"9"]) {
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:URL];
        [self.navigationController presentViewController:sfvc animated:YES completion:nil];
    } else {
        if (![[UIApplication sharedApplication] openURL:URL]) {
            NSLog(@"%@%@",@"Failed to open url:",[URL description]);
        }
    }

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
