//
//  ARCloudMenuViewController.h
//  ARCloud
//
//  Created by 王冠宇 on 16/7/4.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ARCloudMenuDelegate <NSObject>

- (BOOL) menuProcess:(NSString *)itemName value:(BOOL) value;
- (void) menuDidExit;

@end

@interface ARCloudMenuViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<ARCloudMenuDelegate> menuDelegate;

@property (nonatomic, readwrite) BOOL showingMenu;
@property (nonatomic, copy) NSString *dismissItemName;
@property (nonatomic, copy) NSString *sampleAppFeatureName;
@property (nonatomic, copy) NSString *backSegueId;
@property (nonatomic, readwrite) BOOL windowTapGestureRecognizerAdded;
@property (nonatomic, strong) UITapGestureRecognizer * windowTapGestureRecognizer;

+ (CGFloat)getMenuWidthScale;
- (void)setValue:(BOOL)value forMenuItem:(NSString*)name;

@end
