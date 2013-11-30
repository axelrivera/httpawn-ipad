//
//  RequestEditViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/30/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RequestEditViewController.h"

#import "RequestViewCell.h"

@interface RequestEditViewController ()

@end

@implementation RequestEditViewController

- (id)init
{
    self = [super initWithNibName:@"RequestEditViewController" bundle:nil];
    if (self) {
        self.title = @"Edit Request";
    }
    return self;
}

- (id)initWithRequest:(RCRequest *)request
{
    self = [self init];
    if (self) {
        _request = request;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(dismissAction:)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(saveAction:)];

    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0,
                                                                       0.0,
                                                                       self.tableView.frame.size.width - 30.0,
                                                                       37.0)];
    self.nameTextField.placeholder = @"Enter Request Name";
    self.nameTextField.contentVerticalAlignment = UIViewContentModeCenter;
    self.nameTextField.font = [UIFont systemFontOfSize:15.0];
    self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;

    self.nameTextField.text = self.request.requestName;

    self.descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(0.0,
                                                                            0.0,
                                                                            self.tableView.frame.size.width - 30.0,
                                                                            60.0)];
    self.descriptionTextView.font = [UIFont systemFontOfSize:15.0];

    self.descriptionTextView.text = self.request.requestDescription;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selector Methods

- (void)dismissAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveAction:(id)sender
{
    [self.view endEditing:YES];

    NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSString *requestName = [self.nameTextField.text stringByTrimmingCharactersInSet:characterSet];
    NSString *requestDescription = [self.descriptionTextView.text stringByTrimmingCharactersInSet:characterSet];

    if (!IsEmpty(requestName)) {
        self.request.requestName = requestName;
    }

    if (!IsEmpty(requestDescription)) {
        self.request.requestDescription = requestDescription;
    }

    if (self.completionBlock) {
        self.completionBlock();
    }

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *URLIdentifier = @"URLCell";
    static NSString *NameIdentifier = @"NameCell";
    static NSString *DescriptionIdentifier = @"DescriptionCell";

    if (indexPath.section == 0) {
        RequestViewCell *cell = [tableView dequeueReusableCellWithIdentifier:URLIdentifier];
        if (cell == nil) {
            cell = [[RequestViewCell alloc] initWithReuseIdentifier:URLIdentifier];
        }

        [cell setRequest:self.request ignoreName:YES];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }

    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NameIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NameIdentifier];
            cell.accessoryView = self.nameTextField;
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DescriptionIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DescriptionIdentifier];
        cell.accessoryView = self.descriptionTextView;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (section == 0) {
        title = @"URL String";
    } else if (section == 1) {
        title = @"Request Name";
    } else if (section == 2) {
        title = @"Request Description";
    }
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    if (indexPath.section == 0) {
        height = [RequestViewCell cellHeight];
    } else if (indexPath.section == 2) {
        height = 85.0;
    }
    return height;
}

@end
