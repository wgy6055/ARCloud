//
//  GYNotificationBar.m
//  ARCloud
//
//  Created by 王冠宇 on 16/8/15.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import "GYNotificationBar.h"

@interface GYNotificationBar()

@property (strong, nonatomic) UILabel *labelString;
@property (assign, nonatomic) BOOL isShowingBar;

@end

@implementation GYNotificationBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.labelString = [UILabel new];
        self.labelString.textColor = [UIColor whiteColor];
        [self setAlpha:0.5];
        self.labelString.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 100, 0, [UIScreen mainScreen].bounds.size.width, 50);
        [self addSubview:self.labelString];
        [self setBackgroundColor:[UIColor blackColor]];
        
        self.isShowingBar = NO;
    }
    return self;
}

- (void)showNotificationBarWithString:(NSString *)string {
    if (!self.isShowingBar) {
        self.isShowingBar = YES;
        self.labelString.text = string;
        [UIView animateWithDuration:1.0
                         animations:^{
                             CGRect temp = self.frame;
                             temp.origin = CGPointMake(0, 0);
                             self.frame = temp;
                         }];
        [self performSelector:@selector(unshowNotificationBar) withObject:nil afterDelay:2.0f];
    }
}

- (void)unshowNotificationBar {
    if (self.isShowingBar) {
        [UIView animateWithDuration:1.0
                         animations:^{
                             CGRect temp = self.frame;
                             temp.origin = CGPointMake(0, -50);
                             self.frame = temp;
                         }];
        self.labelString = nil;
    }
}

@end
