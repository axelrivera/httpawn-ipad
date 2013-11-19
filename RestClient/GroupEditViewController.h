//
//  GroupEditViewController.h
//  RestClient
//
//  Created by Axel Rivera on 11/18/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RCGroupObject.h"

typedef NS_ENUM(NSInteger, GroupEditType) {
    GroupEditTypeCreate,
    GroupEditTypeModify
};

@protocol GroupEditViewControllerDelegate;

@interface GroupEditViewController : UITableViewController

@property (weak, nonatomic) id <GroupEditViewControllerDelegate> delegate;

@property (strong, nonatomic) UITextField *nameTextField;

@property (assign, nonatomic) GroupEditType editType;
@property (strong, nonatomic) RCGroupObject *groupObject;

- (id)initWithGroupObject:(RCGroupObject *)groupObject;

@end

@protocol GroupEditViewControllerDelegate <NSObject>

- (void)groupEditViewControllerDidCancel:(GroupEditViewController *)controller;
- (void)groupEditViewController:(GroupEditViewController *)controller
              didFinishWithType:(GroupEditType)editType
                         object:(RCGroupObject *)groupObject;

@end
