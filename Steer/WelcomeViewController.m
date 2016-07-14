//
//  ViewController.m
//  Steer
//
//  Created by Enterpi iOS on 06/07/16.
//  Copyright © 2016 Enterpi iOS. All rights reserved.
//

#import "WelcomeViewController.h"
#import <IndoorsSDK/IndoorsSurfaceBuilder.h>

@interface WelcomeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImgView;
@property (weak, nonatomic) IBOutlet UIButton *letsGoBtn;
@property (weak, nonatomic) IBOutlet UIStackView *logoHolderVStackView;
@property (weak, nonatomic) IBOutlet UILabel *wcToEpiLabel;
@property (weak, nonatomic) IBOutlet UILabel *csdLabel;
@property (weak, nonatomic) IBOutlet UILabel *tourtextlabel;
@property (strong, nonatomic) NSTimer *timer;


@end

@implementation WelcomeViewController

#pragma mark - View LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self prepareView];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private API

- (void)prepareView {
    
    
    
    self.letsGoBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.letsGoBtn.layer.borderWidth = 2.0;
    self.letsGoBtn.layer.cornerRadius = 2.0;
    
    
    __block CGRect logoFrame = _logoImgView.frame;
    self.logoImgView.frame = CGRectMake(0, 0, 560, 560);
    
    
    [UIView animateWithDuration:0.8 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.logoImgView.alpha = 1.0;
        self.logoImgView.frame = logoFrame;

    } completion:^(BOOL finished) {
        
        [UIView animateKeyframesWithDuration:1.5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
            
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
                self.wcToEpiLabel.alpha = 1.0;
            }];
            
            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
                self.csdLabel.alpha = 1.0;
            }];
            
        } completion:^(BOOL finished) {
            
            [UIView animateKeyframesWithDuration:0.5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
                
                [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
                    self.tourtextlabel.alpha = 1.0;
                    self.letsGoBtn.alpha = 1.0;

                }];
                
            } completion:^(BOOL finished) {
                [self shakeGoBtn];
                
                if (self.timer) {
                    [self.timer invalidate];
                    self.timer = nil;
                }

                    self.timer =   [NSTimer scheduledTimerWithTimeInterval:5
                                                           target:self
                                                         selector:@selector(shakeGoBtn)
                                                         userInfo:nil
                                                          repeats:YES];
                
            }];

            
            
        }];
        
        
    }];
    
}

- (void)shakeGoBtn {
      
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.07];
    [animation setRepeatCount:2.0];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([self.letsGoBtn center].x - 5.0f, [self.letsGoBtn center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([self.letsGoBtn center].x + 5.0f, [self.letsGoBtn center].y)]];
    [[self.letsGoBtn layer] addAnimation:animation forKey:@"position"];
    
}

@end
