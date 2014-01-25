//
//  JSONObjectViewController.h
//  RestClient
//
//  Created by Axel Rivera on 1/10/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JSONObjectViewControllerDelegate;

@interface JSONObjectViewController : UIViewController

@property (weak, nonatomic) id <JSONObjectViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (strong, nonatomic) RCJSONObject *object;

- (instancetype)initWithContainerObject:(RCJSONObject *)object;

@end

@protocol JSONObjectViewControllerDelegate <NSObject>

- (void)JSONObjectViewController:(JSONObjectViewController *)controller didFinishWithObject:(RCJSONObject *)object;

@end
