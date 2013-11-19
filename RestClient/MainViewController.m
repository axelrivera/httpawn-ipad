//
//  MainViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/12/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "MainViewController.h"

#import "GroupEditViewController.h"

@interface MainViewController () <GroupEditViewControllerDelegate>

@property (strong, nonatomic) UIBarButtonItem *addGroupItem;

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

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                          target:self
                                                                                          action:@selector(modifyAction:)];

    self.addGroupItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                      target:self
                                                                      action:@selector(addGroupAction:)];

    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"Groups", @"History" ]];
    [self.segmentedControl setWidth:120.0 forSegmentAtIndex:MainViewTypeGroup];
    [self.segmentedControl setWidth:120.0 forSegmentAtIndex:MainViewTypeHistory];

    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlChanged:)
                    forControlEvents:UIControlEventValueChanged];

    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];

    UIBarButtonItem *segmentedItem = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];

    self.toolbarItems = @[ flexibleItem, segmentedItem, flexibleItem ];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.segmentedControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
        self.segmentedControl.selectedSegmentIndex = MainViewTypeGroup;
        [self segmentedControlChanged:self.segmentedControl];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (NSArray *)dataSource
{
    NSArray *array = nil;
    if (self.segmentedControl.selectedSegmentIndex == MainViewTypeHistory) {
        array = self.history;
    } else {
        array = self.groups;
    }

    return array;
}

#pragma mark - Selector Methods

- (void)segmentedControlChanged:(UISegmentedControl *)segmentedControl
{
    if (segmentedControl.selectedSegmentIndex == MainViewTypeGroup) {
        self.title = @"Groups";
        self.navigationItem.rightBarButtonItem = self.addGroupItem;
    } else {
        self.title = @"History";
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

- (void)modifyAction:(id)sender
{
    
}

#pragma mark - UIViewControllerDelegate Methods

- (void)groupEditViewControllerDidCancel:(GroupEditViewController *)controller
{
    [controller.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)groupEditViewController:(GroupEditViewController *)controller
              didFinishWithType:(GroupEditType)editType
                         object:(RCGroupObject *)groupObject
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    id object = [self dataSource][indexPath.row];

    if (self.segmentedControl.selectedSegmentIndex == MainViewTypeGroup) {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.textLabel.text = [object name];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    RCGroupObject *groupObject = self.groups[indexPath.row];
    GroupEditViewController *controller = [[GroupEditViewController alloc] initWithGroupObject:groupObject];
    controller.delegate = self;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

@end
