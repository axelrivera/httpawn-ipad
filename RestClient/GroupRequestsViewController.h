//
//  GroupRequestsViewController.h
//  RestClient
//
//  Created by Axel Rivera on 11/29/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupRequestsViewControllerDelegate;

@interface GroupRequestsViewController : UITableViewController

@property (weak, nonatomic) id <GroupRequestsViewControllerDelegate> delegate;
@property (strong, nonatomic) RCGroup *group;

- (id)initWithGroup:(RCGroup *)group;

@end

@protocol GroupRequestsViewControllerDelegate <NSObject>

- (void)groupRequestsViewController:(GroupRequestsViewController *)controller didSelectRequest:(RCRequest *)request;

@end
