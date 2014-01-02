//
//  MainViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/12/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "MainViewController.h"

#import "GroupEditViewController.h"
#import "GroupRequestsViewController.h"
#import "RequestViewCell.h"

@interface MainViewController ()
<GroupEditViewControllerDelegate, UIAlertViewDelegate, GroupRequestsViewControllerDelegate>

@property (strong, nonatomic) UIBarButtonItem *addGroupItem;
@property (strong, nonatomic) UIBarButtonItem *clearHistoryItem;

- (NSArray *)dataSource;

@end

@implementation MainViewController

- (instancetype)init
{
    self = [super initWithNibName:@"MainViewController" bundle:nil];
    if (self) {
        self.title = @"HTTPawn";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);

    [self.navigationController setToolbarHidden:NO animated:NO];

    self.addGroupItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                      target:self
                                                                      action:@selector(addGroupAction:)];
    
    self.clearHistoryItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear All"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(clearHistoryAction:)];

    if (!IsEmpty([RestClientData sharedData].groups)) {
        self.navigationItem.leftBarButtonItem = [self editButtonItem];
    }

    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"Groups", @"History" ]];
    [self.segmentedControl setWidth:130.0 forSegmentAtIndex:RCRequestTypeGroup];
    [self.segmentedControl setWidth:130.0 forSegmentAtIndex:RCRequestTypeHistory];

    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlChanged:)
                    forControlEvents:UIControlEventValueChanged];

    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];

    UIBarButtonItem *segmentedItem = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];

    self.toolbarItems = @[ flexibleItem, segmentedItem, flexibleItem ];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(groupUpdated:)
                                                 name:GroupDidUpdateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(historyUpdated:)
                                                 name:HistoryDidUpdateNotification
                                               object:nil];
    
    self.segmentedControl.selectedSegmentIndex = RCRequestTypeGroup;
    [self segmentedControlChanged:self.segmentedControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];

    if (IsEmpty([RestClientData sharedData].history)) {
        self.clearHistoryItem.enabled = NO;
    } else {
        self.clearHistoryItem.enabled = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:GroupDidUpdateNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:HistoryDidUpdateNotification];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    
    if (self.segmentedControl.selectedSegmentIndex == RCRequestTypeGroup) {
        if (editing) {
            self.navigationItem.rightBarButtonItem = nil;
        } else {
            self.navigationItem.rightBarButtonItem = self.addGroupItem;
        }
    }
}

#pragma mark - Private Methods

- (NSArray *)dataSource
{
    NSArray *array = nil;
    if (self.segmentedControl.selectedSegmentIndex == RCRequestTypeHistory) {
        array = [RestClientData sharedData].history;
    } else {
        array = [RestClientData sharedData].groups;
    }

    return array;
}

#pragma mark - Selector Methods

- (void)segmentedControlChanged:(UISegmentedControl *)segmentedControl
{
    [self setEditing:NO animated:YES];

    if (segmentedControl.selectedSegmentIndex == RCRequestTypeGroup) {
        self.title = @"Groups";
        if (!IsEmpty([RestClientData sharedData].groups)) {
            self.navigationItem.leftBarButtonItem = [self editButtonItem];
        }
        self.navigationItem.rightBarButtonItem = self.addGroupItem;
    } else {
        if (IsEmpty([RestClientData sharedData].history)) {
            self.clearHistoryItem.enabled = NO;
        } else {
            self.clearHistoryItem.enabled = YES;
        }

        self.title = @"History";
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = self.clearHistoryItem;
    }

    [self.tableView reloadData];
}

- (void)addGroupAction:(id)sender
{
    GroupEditViewController *controller = [[GroupEditViewController alloc] initWithType:GroupEditTypeCreate
                                                                            groupObject:nil];
    controller.delegate = self;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.navigationController presentViewController:navController animated:YES completion:nil];
    
}

- (void)clearHistoryAction:(id)sender
{
    NSString *message = @"Are you sure you want to remove all the requests available in history?";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Clear History"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Continue", nil];

    [alertView show];
}

- (void)groupUpdated:(NSNotification *)notification
{
    if (self.segmentedControl.selectedSegmentIndex == RCRequestTypeGroup) {
        [self.tableView reloadData];
    }
}

- (void)historyUpdated:(NSNotification *)notification
{
    if (self.segmentedControl.selectedSegmentIndex == RCRequestTypeHistory) {
        [self.tableView reloadData];

        if (IsEmpty([RestClientData sharedData].history)) {
            self.clearHistoryItem.enabled = NO;
        } else {
            self.clearHistoryItem.enabled = YES;
        }
    }
}

#pragma mark - UIViewControllerDelegate Methods

- (void)groupEditViewController:(GroupEditViewController *)controller
              didFinishWithType:(GroupEditType)editType
                         object:(RCGroup *)groupObject
{
    if (editType == GroupEditTypeCreate) {
        [[RestClientData sharedData].groups addObject:groupObject];
        if (!IsEmpty([RestClientData sharedData].groups) && self.navigationItem.leftBarButtonItem == nil) {
            self.navigationItem.leftBarButtonItem = [self editButtonItem];
        }
    } else {
        NSInteger index = [[RestClientData sharedData].groups indexOfObject:groupObject];
        if (index != NSNotFound) {
            [[RestClientData sharedData].groups replaceObjectAtIndex:index withObject:groupObject];
        }
    }
    
    [self.tableView reloadData];

    [controller.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)groupEditViewController:(GroupEditViewController *)controller shouldDeleteGroupObject:(RCGroup *)object
{
    NSInteger index = [[RestClientData sharedData].groups indexOfObject:object];
    if (index != NSNotFound) {
        [[RestClientData sharedData].groups removeObjectAtIndex:index];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
        if (IsEmpty([RestClientData sharedData].groups)) {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }

    [self.delegate shouldUpdateRequest:nil requestType:-1];

    [controller.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)groupEditViewControllerDidCancel:(GroupEditViewController *)controller
{
    [controller.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)groupRequestsViewController:(GroupRequestsViewController *)controller didSelectRequest:(RCRequest *)request
{
    [self.delegate shouldUpdateRequest:request requestType:RCRequestTypeGroup];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self dataSource] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *GroupIdentifier = @"GroupCell";
    static NSString *HistoryIdentifier = @"HistoryCell";

    if (self.segmentedControl.selectedSegmentIndex == RCRequestTypeGroup) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GroupIdentifier];
        }

        id object = [self dataSource][indexPath.row];

        cell.textLabel.text = [object groupName];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        return cell;
    }

    RequestViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HistoryIdentifier];
    if (cell == nil) {
        cell = [[RequestViewCell alloc] initWithReuseIdentifier:HistoryIdentifier];
    }

    RCRequest *request = [self dataSource][indexPath.row];

    [cell setRequest:request];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.segmentedControl.selectedSegmentIndex == RCRequestTypeGroup) {
        RCGroup *group = [self dataSource][indexPath.row];
        GroupRequestsViewController *controller = [[GroupRequestsViewController alloc] initWithGroup:group];
        controller.delegate = self;

        [self.navigationController pushViewController:controller animated:YES];
    } else {
        RCRequest *request = [self dataSource][indexPath.row];
        [self.delegate shouldUpdateRequest:request requestType:self.segmentedControl.selectedSegmentIndex];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    RCGroup *groupObject = [self dataSource][indexPath.row];
    GroupEditViewController *controller = [[GroupEditViewController alloc] initWithType:GroupEditTypeModify
                                                                            groupObject:groupObject];
    controller.delegate = self;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEdit = NO;
    if (self.segmentedControl.selectedSegmentIndex == RCRequestTypeGroup) {
        canEdit = YES;
    }
    return canEdit;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canMove = NO;
    if (self.segmentedControl.selectedSegmentIndex == RCRequestTypeGroup) {
        canMove = YES;
    }
    return canMove;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (self.segmentedControl.selectedSegmentIndex == RCRequestTypeGroup) {
        RCGroup *group = [RestClientData sharedData].groups[fromIndexPath.row];
        [[RestClientData sharedData].groups removeObjectAtIndex:fromIndexPath.row];
        [[RestClientData sharedData].groups insertObject:group atIndex:toIndexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    if (self.segmentedControl.selectedSegmentIndex == RCRequestTypeHistory) {
        height = [RequestViewCell cellHeight];
    }
    return height;
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[RestClientData sharedData].history removeAllObjects];
        [self.tableView reloadData];
        self.clearHistoryItem.enabled = NO;
    }
}

@end
