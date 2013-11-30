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
<GroupEditViewControllerDelegate, UIActionSheetDelegate, GroupRequestsViewControllerDelegate>

@property (strong, nonatomic) UIBarButtonItem *addGroupItem;
@property (strong, nonatomic) UIBarButtonItem *clearHistoryItem;

- (NSArray *)dataSource;

@end

@implementation MainViewController

- (id)init
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
    if (segmentedControl.selectedSegmentIndex == RCRequestTypeGroup) {
        self.title = @"Groups";
        self.navigationItem.leftBarButtonItem = [self editButtonItem];
        self.navigationItem.rightBarButtonItem = self.addGroupItem;
    } else {
        self.title = @"History";
        self.navigationItem.leftBarButtonItem = self.clearHistoryItem;
        self.navigationItem.rightBarButtonItem = nil;
    }

    [self.tableView reloadData];
}

- (void)addGroupAction:(id)sender
{
    GroupEditViewController *controller = [[GroupEditViewController alloc] init];
    controller.delegate = self;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)clearHistoryAction:(id)sender
{
    NSString *title = @"Are you sure you want to remove all the requests available in history?";
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:@"Clear All"
                                                    otherButtonTitles:nil];
    [actionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
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
    }
}

#pragma mark - UIViewControllerDelegate Methods

- (void)groupEditViewControllerDidCancel:(GroupEditViewController *)controller
{
    [controller.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)groupEditViewController:(GroupEditViewController *)controller
              didFinishWithType:(GroupEditType)editType
                         object:(RCGroup *)groupObject
{
    if (editType == GroupEditTypeCreate) {
        [[RestClientData sharedData].groups addObject:groupObject];
    } else {
        NSInteger index = [[RestClientData sharedData].groups indexOfObject:groupObject];
        if (index != NSNotFound) {
            [[RestClientData sharedData].groups replaceObjectAtIndex:index withObject:groupObject];
        }
    }
    
    [self.tableView reloadData];
    
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
    GroupEditViewController *controller = [[GroupEditViewController alloc] initWithType:GroupEditTypeCreate
                                                                            groupObject:groupObject];
    controller.delegate = self;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if (self.segmentedControl.selectedSegmentIndex == RCRequestTypeGroup) {
            [[RestClientData sharedData].groups removeObjectAtIndex:indexPath.row];
        } else {
            [[RestClientData sharedData].history removeObjectAtIndex:indexPath.row];
        }
        
        [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[RestClientData sharedData].history removeAllObjects];
        [self.tableView reloadData];
    }
}

@end
