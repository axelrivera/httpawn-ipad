//
//  GroupAddViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/25/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "GroupAddViewController.h"

#import "SelectViewController.h"

@interface GroupAddViewController () <SelectViewControllerDelegate>

@end

@implementation GroupAddViewController

- (id)init
{
    self = [super initWithNibName:@"GroupAddViewController" bundle:nil];
    if (self) {
        self.title = @"Add To Group";
    }
    return self;
}

- (id)initWithCurrentGroup:(RCGroup *)currentGroup
{
    self = [self init];
    if (self) {
        _currentGroup = currentGroup;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.delegate respondsToSelector:@selector(groupAddViewControllerDidCancel:)]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(dismissAction:)];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(saveAction:)];
    
    self.groupTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0,
                                                                        0.0,
                                                                        self.tableView.frame.size.width - 30.0,
                                                                        37.0)];
    self.groupTextField.placeholder = @"Enter New Group Name";
    self.groupTextField.contentVerticalAlignment = UIViewContentModeCenter;
    self.groupTextField.font = [UIFont systemFontOfSize:15.0];
    self.groupTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0,
                                                                       0.0,
                                                                       self.tableView.frame.size.width - 30.0,
                                                                       37.0)];
    self.nameTextField.placeholder = @"Enter Request Name";
    self.nameTextField.contentVerticalAlignment = UIViewContentModeCenter;
    self.nameTextField.font = [UIFont systemFontOfSize:15.0];
    self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    self.descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(0.0,
                                                                            0.0,
                                                                            self.tableView.frame.size.width - 30.0,
                                                                            60.0)];
    self.descriptionTextView.font = [UIFont systemFontOfSize:15.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selector Methods

- (void)dismissAction:(id)sender
{
    [self.delegate groupAddViewControllerDidCancel:self];
}

- (void)saveAction:(id)sender
{
    [self.view endEditing:YES];
    
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    RCGroup *group = nil;
    NSString *groupName = [self.groupTextField.text stringByTrimmingCharactersInSet:characterSet];
    
    if (!IsEmpty(groupName)) {
        group = [[RCGroup alloc] init];
        group.groupName = groupName;
    } else {
        group = self.currentGroup;
    }
    
    if (group == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"HTTPawn"
                                                            message:@"You must select an existing group or create a new one."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSString *requestName = [self.nameTextField.text stringByTrimmingCharactersInSet:characterSet];
    NSString *requestDescription = [self.descriptionTextView.text stringByTrimmingCharactersInSet:characterSet];
    
    [self.delegate groupAddViewController:self
                       didFinishWithGroup:group
                              requestName:requestName
                       requestDescription:requestDescription];
}

#pragma mark - UIViewControllerDelegate Methods

- (void)selectViewController:(SelectViewController *)controller didSelectObject:(RCSelect *)object
{
    RCGroup *group = [[RestClientData sharedData] groupWithIdentifier:object.selectValue];
    self.currentGroup = group;
    
    [self.tableView reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (section == 0) {
        rows = 2;
    } else {
        rows = 1;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *GroupSelectIdentifier = @"GroupSelectCell";
    static NSString *GroupCreateIdentifier = @"GroupCreateCell";
    static NSString *RequestNameIdentifier = @"RequestNameCell";
    static NSString *RequestDescriptionIdentifier = @"RequestDescriptionCell";
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupSelectIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                              reuseIdentifier:GroupSelectIdentifier];
                cell.textLabel.font = [UIFont systemFontOfSize:15.0];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
            }
            
            cell.textLabel.text = @"Add To Existing Group";
            
            if (self.currentGroup == nil) {
                cell.detailTextLabel.text = @"Select Group";
            } else {
                cell.detailTextLabel.text = self.currentGroup.groupName;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupCreateIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GroupCreateIdentifier];
            cell.accessoryView = self.groupTextField;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RequestNameIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RequestNameIdentifier];
            cell.accessoryView = self.nameTextField;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RequestDescriptionIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RequestDescriptionIdentifier];
        cell.accessoryView = self.descriptionTextView;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        NSArray *groups = [[RestClientData sharedData] groupSelectObjectsWithSelectedGroup:self.currentGroup];
        SelectViewController *controller = [[SelectViewController alloc] initWithDataSource:groups];
        controller.delegate = self;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (section == 0) {
        title = @"Group";
    } else if (section == 1) {
        title = @"Request Name";
    } else {
        title = @"Request Description";
    }
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    if (indexPath.section == 2) {
        height = 85.0;
    }
    return height;
}

@end
