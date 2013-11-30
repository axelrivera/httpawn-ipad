//
//  GroupAddViewController.h
//  RestClient
//
//  Created by Axel Rivera on 11/25/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupAddViewControllerDelegate;

@interface GroupAddViewController : UITableViewController

@property (weak, nonatomic) id <GroupAddViewControllerDelegate> delegate;

@property (strong, nonatomic) UITextField *groupTextField;
@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UITextView *descriptionTextView;

@property (strong, nonatomic) RCGroup *currentGroup;

- (id)initWithCurrentGroup:(RCGroup *)currentGroup;

@end

@protocol GroupAddViewControllerDelegate <NSObject>

- (void)groupAddViewController:(GroupAddViewController *)controller
            didFinishWithGroup:(RCGroup *)group
                   requestName:(NSString *)requestName
            requestDescription:(NSString *)requestDesription;

@optional

- (void)groupAddViewControllerDidCancel:(GroupAddViewController *)controller;

@end