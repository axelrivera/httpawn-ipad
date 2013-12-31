//
//  GroupRequestsViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/29/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "GroupRequestsViewController.h"

#import "RequestEditViewController.h"
#import "RequestViewCell.h"

@interface GroupRequestsViewController () <UIAlertViewDelegate>

@end

@implementation GroupRequestsViewController

- (instancetype)init
{
    self = [super initWithNibName:@"GroupRequestsViewController" bundle:nil];
    if (self) {
        self.title = @"Requests";
    }
    return self;
}

- (instancetype)initWithGroup:(RCGroup *)group
{
    self = [self init];
    if (self) {
        self.title = group.groupName;
        _group = group;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear All"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(clearAllConfirmation:)];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestsUpdated:)
                                                 name:GroupShouldUpdateRequestsNotification
                                               object:nil];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GroupShouldUpdateRequestsNotification object:nil];
}

#pragma mark - Selector Methods

- (void)clearAllConfirmation:(id)sender
{
    NSString *message = @"Are you sure you want to remove all the requests available in this group?";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Clear Requests"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Continue", nil];

    [alertView show];
}

- (void)clearAction:(id)sender
{
    [self.group removeAllRequests];
    [self.tableView reloadData];
}

- (void)requestsUpdated:(NSNotification *)notification
{
    RCGroup *group = notification.userInfo[kRCGroupKey];
    if ([group isEqual:self.group]) {
        self.group = group;
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.group requests] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    RequestViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[RequestViewCell alloc] initWithReuseIdentifier:CellIdentifier];
    }
    
    RCRequest *request = [self.group requests][indexPath.row];
    [cell setRequest:request];

    cell.accessoryType = UITableViewCellAccessoryDetailButton;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.group removeRequestAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath
{
    RCRequest *request = [self.group requests][fromIndexPath.row];
    [self.group removeRequestAtIndex:fromIndexPath.row];
    [self.group insertRequest:request atIndex:toIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RCRequest *request = [self.group requests][indexPath.row];
    [self.delegate groupRequestsViewController:self didSelectRequest:request];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [RequestViewCell cellHeight];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    RCRequest *request = [self.group requests][indexPath.row];
    RequestEditViewController *controller = [[RequestEditViewController alloc] initWithRequest:request];
    
    controller.completionBlock = ^{
        [self.tableView reloadData];
    };

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self clearAction:alertView];
    }
}

@end
