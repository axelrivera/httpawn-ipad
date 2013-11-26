//
//  MainViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/12/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "MainViewController.h"

#import "GroupEditViewController.h"

@interface MainViewController () <GroupEditViewControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) UIBarButtonItem *addGroupItem;
@property (strong, nonatomic) UIBarButtonItem *clearHistoryItem;

- (NSArray *)dataSource;

@end

@implementation MainViewController

- (id)init
{
    self = [super initWithNibName:@"MainViewController" bundle:nil];
    if (self) {
        self.title = @"Rest Client";
        _groups = [@[] mutableCopy];
        _history = [@[] mutableCopy];
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
    [self.segmentedControl setWidth:120.0 forSegmentAtIndex:RCRequestTypeGroup];
    [self.segmentedControl setWidth:120.0 forSegmentAtIndex:RCRequestTypeHistory];

    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlChanged:)
                    forControlEvents:UIControlEventValueChanged];

    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];

    UIBarButtonItem *segmentedItem = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];

    self.toolbarItems = @[ flexibleItem, segmentedItem, flexibleItem ];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(historyUpdated:)
                                                 name:HistoryDidUpdateNotification
                                               object:nil];

    self.groups = [RestClientData sharedData].groups;
    self.history = [RestClientData sharedData].history;
    
    self.segmentedControl.selectedSegmentIndex = RCRequestTypeGroup;
    [self segmentedControlChanged:self.segmentedControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
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
        array = self.history;
    } else {
        array = self.groups;
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

- (void)historyUpdated:(NSNotification *)notification
{
    self.history = [RestClientData sharedData].history;
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
        [self.groups addObject:groupObject];
    } else {

    }

    [self.tableView reloadData];
    [controller.navigationController dismissViewControllerAnimated:YES completion:nil];
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

        cell.textLabel.text = [object name];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HistoryIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:HistoryIdentifier];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
        cell.detailTextLabel.numberOfLines = 2;
    }

    RCRequest *request = [self dataSource][indexPath.row];

    cell.textLabel.text = request.requestMethod;
    cell.detailTextLabel.text = [request fullURLString];

    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    RCRequest *request = [[self dataSource] objectAtIndex:indexPath.row];
    [self.delegate shouldUpdateRequest:request requestType:self.segmentedControl.selectedSegmentIndex];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    RCGroup *groupObject = self.groups[indexPath.row];
    GroupEditViewController *controller = [[GroupEditViewController alloc] initWithGroupObject:groupObject];
    controller.delegate = self;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if (self.segmentedControl.selectedSegmentIndex == RCRequestTypeGroup) {
            [self.groups removeObjectAtIndex:indexPath.row];
        } else {
            [self.history removeObjectAtIndex:indexPath.row];
        }
        
        [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.history removeAllObjects];
        [self.tableView reloadData];
    }
}

@end
