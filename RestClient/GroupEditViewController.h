//
//  GroupEditViewController.h
//  RestClient
//
//  Created by Axel Rivera on 11/18/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RCGroup.h"

typedef NS_ENUM(NSInteger, GroupEditType) {
    GroupEditTypeCreate,
    GroupEditTypeModify
};

@protocol GroupEditViewControllerDelegate;

@interface GroupEditViewController : UITableViewController

@property (weak, nonatomic) id <GroupEditViewControllerDelegate> delegate;

@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UITextField *baseURLTextField;
@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UISwitch *authenticationSwitch;
@property (strong, nonatomic) UISwitch *redirectSwitch;
@property (strong, nonatomic) UISegmentedControl *parameterSegmentedControl;

@property (assign, nonatomic) GroupEditType editType;
@property (strong, nonatomic) RCGroup *groupObject;
@property (strong, nonatomic) NSArray *dataSource;

- (instancetype)initWithType:(GroupEditType)type groupObject:(RCGroup *)groupObject;

@end

@protocol GroupEditViewControllerDelegate <NSObject>

- (void)groupEditViewController:(GroupEditViewController *)controller
              didFinishWithType:(GroupEditType)editType
                         object:(RCGroup *)object;

@optional

- (void)groupEditViewController:(GroupEditViewController *)controller shouldDeleteGroupObject:(RCGroup *)object;
- (void)groupEditViewControllerDidCancel:(GroupEditViewController *)controller;

@end
