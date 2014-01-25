//
//  JSONValueViewController.h
//  RestClient
//
//  Created by Axel Rivera on 1/10/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JSONValueViewControllerDelegate;

@interface JSONValueViewController : UITableViewController

@property (weak, nonatomic) id <JSONValueViewControllerDelegate> delegate;

@property (strong, nonatomic) UITextField *keyTextField;
@property (strong, nonatomic) UITextField *valueTextField;
@property (strong, nonatomic) UISegmentedControl *booleanSegmentedControl;

@property (assign, nonatomic) RCJSONObjectType parentType;
@property (assign, nonatomic) RCJSONObjectType objectType;
@property (strong, nonatomic) RCJSONObject *object;

- (instancetype)initWithObjectType:(RCJSONObjectType)objectType parentType:(RCJSONObjectType)parentType;
- (instancetype)initWithObject:(RCJSONObject *)object;

@end

@protocol JSONValueViewControllerDelegate <NSObject>

- (void)JSONValueViewControllerDidFinish:(JSONValueViewController *)controller;

- (void)JSONValueViewController:(JSONValueViewController *)controller
        didFinishWithObjectType:(RCJSONObjectType)objectType
                            key:(NSString *)key
                          value:(id)value;

- (void)JSONValueViewControllerDidCancel:(JSONValueViewController *)controller;

@end
